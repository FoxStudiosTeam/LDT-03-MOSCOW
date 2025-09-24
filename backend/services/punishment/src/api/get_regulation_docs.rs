use anyhow::Ok;
use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use orm::prelude::Null;
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
    path = "/get_regulation_docs",
    tag = crate::MAIN_TAG,
    summary = "Get all items in punishment",
    responses(
        (status = 200, description = "Report added!", body=Vec<DocsRequest>),
    )
)]

pub async fn get_regulation_docs(
    State(app): State<AppState>,
    Json(r): Json<DocsRequest>
) -> Result<Response, AppErr> {

    if let Some(title) = r.title {
        let result = app.orm.regulation_docs().select("Where title Like $1").bind(title).fetch().await.into_app_err()?;
        tracing::info!("Result: {:?}", result.len());
        Ok((StatusCode::OK, Json(result)).into_response()).into_app_err()
    }
    else {
        let result = app.orm.regulation_docs().select("").fetch().await.into_app_err()?;
        tracing::info!("Result: {:?}", result.len());
        Ok((StatusCode::OK, Json(result)).into_response()).into_app_err()
    }
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct DocsRequest{
    #[schema(example="Название документа или null")]
    title: Option<String>,
}