use std::collections::HashSet;

use axum::{Json, extract::Multipart, response::{IntoResponse, Response}};
use futures_util::{AsyncReadExt, TryStreamExt};
use http::StatusCode;
use orm::prelude::{Optional::Set, SaveMode::Insert};
use schema::prelude::{ActiveAttachments, OrmAttachments};
use shared::prelude::{AppErr, IntoAppErr};
use tracing::info;

use crate::{ENV, Orm, api::AttachmentParams};

#[derive(Clone)]
pub struct AppState {
    pub orm: Orm,
    pub s3: aws_sdk_s3::Client
}

pub enum FileType {
    Image,
    Pdf,
    Document
}

impl AppState {
    pub async fn upload(&self, params: AttachmentParams, mut multipart: Multipart) -> Result<Response, AppErr> {
        let allowed_mimes = HashSet::from([
            "application/pdf",
            "image/jpeg",
            "image/png",
            "image/gif",
            // .doc
            "application/msword",
            // .docx
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        ]);

        if let Some(field) = multipart.next_field().await.into_app_err()? {
            let name = field.name().unwrap_or("unknown").to_string();
            let file_name = field.file_name().unwrap_or("file").to_string();
            let content_type = field.content_type().map(|ct| ct.to_string());

            tracing::info!("Received field: {} (filename: {})", name, file_name);

            if let Some(mime) = &content_type {
                if !allowed_mimes.contains(mime.as_str()) {
                    return Ok((StatusCode::NOT_FOUND, format!("Invalid MIME type: {}", mime)).into_response());
                }
            } else {
                return Ok((StatusCode::NOT_FOUND, "Missing Content-Type header".to_string()).into_response());
            }

            let mut data = Vec::new();
            let mut field_data = field.map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e)).into_async_read();
            field_data.read_to_end(&mut data).await.into_app_err()?;

            tracing::info!("File {} is valid, size: {} bytes", file_name, data.len());

            let file_id = uuid::Uuid::new_v4();

            let r = self.s3.put_object()
                .bucket(&ENV.S3_BUCKET)
                .key(&format!("attachments/{}", file_id))
                .body(aws_sdk_s3::primitives::ByteStream::new(data.into()))
                .metadata("filename", file_name.clone())
                .send()
                .await
                .into_app_err()
                ?;
            info!("Uploaded to s3: {:#?}", r);

            let res = self.orm.attachments().save(ActiveAttachments{
                original_filename: Set(file_name),
                uuid: Set(file_id),
                base_entity_uuid: Set(params.id),
                content_type: Set(Some(content_type.unwrap_or("application/octet-stream".to_string()))),
            }, Insert).await?;

            return if let Some(attachment) = res {
                Ok((StatusCode::OK, Json(attachment)).into_response())
            } else {
                Ok((StatusCode::NOT_MODIFIED, "Attachment not found (unreachable?)".to_string()).into_response())
            }
        }
        Ok((StatusCode::BAD_REQUEST, "Missing file".to_string()).into_response())
    }
}