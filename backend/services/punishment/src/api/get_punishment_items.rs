use std::{collections::HashMap};

use axum::{Json, extract::{Query, State}, http::StatusCode, response::{IntoResponse, Response}};
use serde::{Deserialize, Serialize};
use shared::{prelude::{AppErr, IntoAppErr}};
use tracing::info;
use schema::prelude::*;
use utoipa::ToSchema;
use uuid::Uuid;
use crate::{AppState};


#[derive(ToSchema, Serialize)]
pub struct PunishmentItemWithAttachments {
    pub punishment_item: PunishmentItem,
    pub attachments: Vec<Attachments>,
}

#[derive(sqlx::FromRow, Debug)]
struct ItemWithAttachment {
    #[sqlx(flatten)]
    punishment_item: PunishmentItem,
    #[sqlx(flatten)]
    attachment: OptionalAttachments,
}

#[derive(sqlx::FromRow, Default, Debug)]
pub struct OptionalAttachments {
    pub original_filename: Option<String>,
    pub attachment_uuid: Option<uuid::Uuid>,
    pub base_entity_uuid: Option<uuid::Uuid>,
    pub file_uuid: Option<uuid::Uuid>,
    pub content_type: Option<String>,
}

impl OptionalAttachments {
    fn into_attachments(self) -> Option<Attachments> {
        Some(Attachments {
            original_filename: self.original_filename?,
            uuid: self.attachment_uuid?,
            base_entity_uuid: self.base_entity_uuid?,
            file_uuid: self.file_uuid?,
            content_type: self.content_type,
        })
    }
}

impl ItemWithAttachment {
    fn split(self) -> PunishmentItemWithAttachments {
        PunishmentItemWithAttachments{
            punishment_item: self.punishment_item,
            attachments: self.attachment.into_attachments().map(|v| vec![v]).unwrap_or_default(),
        }
    }
}


#[utoipa::path(
    get,
    path = "/get_punishment_items",
    tag = crate::MAIN_TAG,
    summary = "Get all items in punishment",
    responses(
        (status = 200, description = "Punishment items fetched", body=Vec<PunishmentItemWithAttachments>),
    )
)]
pub async fn get_punishment_items(
    State(app): State<AppState>,
    Query(r): Query<PunishmentItemsRequest>,
) -> Result<Response, AppErr> {
    let rows = sqlx::query_as::<_, ItemWithAttachment>("
        SELECT pi.*, 
        a.uuid AS attachment_uuid,
        a.original_filename,
        a.base_entity_uuid,
        a.file_uuid,
        a.content_type
        FROM journal.punishment_item pi
        LEFT JOIN attachment.attachments a ON a.base_entity_uuid = pi.uuid
        WHERE pi.punishment = $1
    ").bind(r.punishment_id).fetch_all(app.orm.get_executor()).await.into_app_err()?;

    info!("{:#?}", rows);

    let mut hm = HashMap::new();

    for row in rows {
        let a = row.attachment.into_attachments();
        let e = &mut hm.entry(row.punishment_item.uuid.clone())
            .or_insert_with(|| PunishmentItemWithAttachments{
                attachments: vec![], 
                punishment_item: row.punishment_item
            })
            .attachments;
        let Some(a) = a else {continue};
        e.push(a);  
    }
    let v = hm.into_values().collect::<Vec<_>>();
    Ok((StatusCode::OK, Json(v)).into_response())
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]
pub struct PunishmentItemsRequest{
    #[schema(example=Uuid::new_v4)]
    punishment_id: uuid::Uuid,
}