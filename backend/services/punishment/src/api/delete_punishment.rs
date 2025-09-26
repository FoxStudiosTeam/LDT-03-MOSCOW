use axum::{Json, extract::{Path, State}, http::StatusCode, response::{IntoResponse, Response}};
use serde::Serialize;
use shared::prelude::{AppErr};
use schema::prelude::*;
use uuid::Uuid;
use crate::{AppState, api::ErrorExample};

#[utoipa::path(
    delete,
    path = "/delete/{uuid}",
    tag = crate::MAIN_TAG,
    summary = "Delete punishment by uuid",
    responses(
        (status = 200, description = "Punishment deleted", body=OkMessage),
        (status = 404, description = "Punishment not found", body=ErrorExample),
    )
)]

pub async fn delete_punishment(
    State(app): State<AppState>,
    Path(r): Path<Uuid>
) -> Result<Response, AppErr> {
        app.orm.punishment().delete_by_pk(&r).await?
        .ok_or_else(||AppErr::default().with_status(StatusCode::NOT_FOUND).with_response("Punishment not found"))?;
        Ok((StatusCode::OK, Json(OkMessage{message:"Punishment deleted".to_string()})).into_response())
}

#[derive(utoipa::ToSchema, Serialize, Debug)]

struct OkMessage {
    #[schema(example="Punishment deleted")]
    message: String
}