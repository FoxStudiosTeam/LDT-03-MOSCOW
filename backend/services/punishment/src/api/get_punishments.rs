use anyhow::Ok;
use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use orm::prelude::Optional::Set;
use serde::{Deserialize, Serialize};
use shared::prelude::{AppErr, IntoAppErr};
use tracing::info;
use tracing_subscriber::field::debug;
use utoipa_axum::{router::OpenApiRouter, routes};
use schema::prelude::*;
use uuid::Uuid;
use crate::AppState;

#[utoipa::path(
    post,
    path = "/get_punishments",
    tag = crate::MAIN_TAG,
    summary = "Get all punishments in project",
    responses(
        (status = 200, description = "Report added!", body=Uuid),
    )
)]

pub async fn get_punishments(
    State(app): State<AppState>,
    Json(r): Json<GetPunishmentsRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    let result = app.orm.punishment().select("where project = $1").bind(&r.project).fetch().await.into_app_err()?;
    tracing::info!("Result: {:?}", result.len());
    Ok((StatusCode::OK, Json(result)).into_response()).into_app_err()
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct GetPunishmentsRequest{
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    project: uuid::Uuid,
}