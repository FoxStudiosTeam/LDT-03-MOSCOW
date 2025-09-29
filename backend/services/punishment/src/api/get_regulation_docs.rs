use axum::{Json, extract::{Query, State}, http::StatusCode, response::{IntoResponse, Response}};
use serde::{Deserialize};
use shared::prelude::{AppErr, IntoAppErr};
use schema::prelude::*;
use utoipa::IntoParams;
use crate::AppState;

#[utoipa::path(
    get,
    path = "/get_regulation_docs",
    tag = crate::ANY_TAG,
    params(DocsRequest),
    summary = "Get all regulation documents",
    responses(
        (status = 200, description = "Report added!", body=Vec<RegulationDocs>),
    )
)]

pub async fn get_regulation_docs(
    State(app): State<AppState>,
    Query(r): Query<DocsRequest>
) -> Result<Response, AppErr> {
    let title_opt = r.title.as_ref()
    .map(|t| t.trim()).filter(|t| !t.is_empty() || *t == " "); 

    if let Some(title) = title_opt {
        let title_formatted = format!("%{}%",title);
        tracing::info!("Title: {:?}", title);
        let result = app.orm.regulation_docs().select("where title ILIKE $1 ").bind(&title_formatted).fetch().await.into_app_err()?;
        tracing::info!("Result: {:?}", result.len());
        Ok((StatusCode::OK, Json(result)).into_response())
    }
    else {
        let result = app.orm.regulation_docs().select("").fetch().await.into_app_err()?;
        tracing::info!("Result: {:?}", result.len());
        Ok((StatusCode::OK, Json(result)).into_response())
    }
}

#[derive(utoipa::ToSchema, Deserialize, Debug, IntoParams)]

pub struct DocsRequest{
    #[schema(example="Название документа или null")]
    #[param(example="Название документа или null")]
    title: Option<String>,
}