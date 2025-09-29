use axum::{Json, extract::{Query, State}, http::StatusCode, response::{IntoResponse, Response}};
use serde::{Deserialize};
use shared::prelude::{AppErr};
use tracing::info;
use schema::prelude::*;
use utoipa::IntoParams;
use crate::{AppState, api::ErrorExample};

#[utoipa::path(
    get,
    path = "/get_punishments",
    tag = crate::ANY_TAG,
    params(PunishmentsRequest),
    summary = "Get all punishments in project",
    responses(
        (status = 200, description = "Punishments fetched", body=Vec<Punishment>),
        (status = 404, description = "Project not found", body=ErrorExample),
    )
)]

pub async fn get_punishments(
    State(app): State<AppState>,
    Query(r): Query<PunishmentsRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    app.orm.project().select_by_pk(&r.project).await?.ok_or_else(|| AppErr::default()
    .with_status(StatusCode::NOT_FOUND)
    .with_err_response("Project not found"))?;
    let result = app.orm.punishment().select("where project = $1").bind(&r.project).fetch().await?;
    tracing::info!("Result: {:?}", result.len());
    Ok((StatusCode::OK, Json(result)).into_response())
}

#[derive(utoipa::ToSchema, Deserialize, Debug, IntoParams)]

pub struct PunishmentsRequest{
    #[schema(example=uuid::Uuid::new_v4)]
    #[param(example=uuid::Uuid::new_v4)]
    project: uuid::Uuid,
}