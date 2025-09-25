use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use shared::prelude::{AppErr, IntoAppErr};
use schema::prelude::*;
use crate::AppState;

#[utoipa::path(
    get,
    path = "/get_statuses",
    tag = crate::MAIN_TAG,
    summary = "Get all punishment statuses",
    responses(
        (status = 200, description = "Punishment statuses fetched", body=Vec<PunishmentStatuses>),
    )
)]

pub async fn get_punishment_statuses(
    State(app): State<AppState>
) -> Result<Response, AppErr> {
        let result = app.orm.punishment_statuses().select("").fetch().await.into_app_err()?;
        tracing::info!("Result: {:?}", result.len());
        Ok((StatusCode::OK, Json(result)).into_response())
}