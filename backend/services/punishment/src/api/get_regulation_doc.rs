use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use serde::{Deserialize};
use shared::prelude::{AppErr, IntoAppErr};
use tracing::info;
use schema::prelude::*;
use crate::AppState;

#[utoipa::path(
    post,
    path = "/get_doc",
    tag = crate::MAIN_TAG,
    summary = "Get regulation document",
    responses(
        (status = 200, description = "Punishments fetched", body=RegulationDocs),
        (status = 404, description = "Regulation document not found", body=String, example="Regulation document not found"),
    )
)]

pub async fn get_regulation_doc(
    State(app): State<AppState>,
    Json(r): Json<DocsRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    let raw_result = app.orm.regulation_docs().select_by_pk(&r.uuid).await.into_app_err()?;
    let result = raw_result.ok_or_else(|| 
        AppErr::default().with_status(StatusCode::NOT_FOUND)
        .with_response("Regulation document not found".into_response()))?;
    
    tracing::info!("Result: {:?}", result);
    Ok((StatusCode::OK, Json(result)).into_response())
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct DocsRequest{
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    uuid: uuid::Uuid,
}