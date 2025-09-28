use axum::{Json, extract::{Query, State}, http::StatusCode, response::{IntoResponse, Response}};
use serde::{Deserialize, Serialize};
use shared::prelude::{AppErr};
use schema::prelude::*;
use utoipa::IntoParams;
use uuid::Uuid;
use crate::{AppState, api::ErrorExample};

#[utoipa::path(
    delete,
    path = "/delete",
    tag = crate::ANY_TAG,
    params(DeletePunishmentRequest),
    summary = "Delete punishment by uuid",
    responses(
        (status = 200, description = "Punishment deleted", body=OkMessage),
        (status = 404, description = "Punishment not found", body=ErrorExample),
    )
)]

pub async fn delete_punishment(
    State(app): State<AppState>,
    Query(r): Query<DeletePunishmentRequest>
) -> Result<Response, AppErr> {
        app.orm.punishment().delete_by_pk(&r.uuid).await?
        .ok_or_else(||AppErr::default().with_status(StatusCode::NOT_FOUND).with_response("Punishment not found"))?;
        Ok((StatusCode::OK, Json(OkMessage{message:"Punishment deleted".to_string()})).into_response())
}

#[derive(utoipa::ToSchema, Deserialize, Debug, IntoParams)]

pub struct DeletePunishmentRequest {
    #[schema(example=Uuid::new_v4)]
    #[param(example=Uuid::new_v4)]
    uuid: Uuid
}

#[derive(utoipa::ToSchema, Serialize, Debug)]

struct OkMessage {
    #[schema(example="Punishment deleted")]
    message: String
}