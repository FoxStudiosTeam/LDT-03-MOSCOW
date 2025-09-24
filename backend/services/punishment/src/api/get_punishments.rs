use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use serde::{Deserialize};
use shared::prelude::{AppErr, IntoAppErr};
use tracing::info;
use schema::prelude::*;
use crate::AppState;

#[utoipa::path(
    post,
    path = "/get_punishments",
    tag = crate::MAIN_TAG,
    summary = "Get all punishments in project",
    responses(
        (status = 200, description = "Punishments fetched", body=Vec<Punishment>),
    )
)]

pub async fn get_punishments(
    State(app): State<AppState>,
    Json(r): Json<PunishmentsRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    let result = app.orm.punishment().select("where project = $1").bind(&r.project).fetch().await.into_app_err()?;
    tracing::info!("Result: {:?}", result.len());
    Ok((StatusCode::OK, Json(result)).into_response())
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct PunishmentsRequest{
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    project: uuid::Uuid,
}