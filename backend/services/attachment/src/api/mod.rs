use auth_jwt::prelude::Role;
use axum::{Json, extract::{Multipart, State}};
use serde::Deserialize;
use utoipa::ToSchema;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

use crate::AppState;




pub fn router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(
            routes!(
                upload
            )
        )
        .with_state(state)
        // .layer(auth_jwt::prelude::AuthLayer::new(Role::Operator | Role::Customer | Role::Inspector))
        .layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
}


#[derive(ToSchema, Deserialize, Debug)]
pub struct UploadRequest {

}

#[utoipa::path(
    post,
    path = "/attachment",
    tag = crate::MAIN_TAG,
    request_body(description = "Multipart file", content_type = "multipart/form-data"),
    summary = "Attachment",
    responses(
        (status = 200, description = "Success", body = UploadRequest),
        (status = 401, description = "Unauthorized"),
        (status = 403, description = "Forbidden"),
        (status = 404, description = "Not Found"),
    )
)]
#[axum::debug_handler]
pub async fn upload(
    State(app) : State<AppState>,
    // multipart : axum::extract::Multipart,
    Json(r) : Json<UploadRequest>,
) {
    tracing::info!("Aboba")
}