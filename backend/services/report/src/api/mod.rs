use std::ops::Add;

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

pub fn make_router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(
            role_secured_route
        ))
        .with_state(state)
}
#[utoipa::path(
    post,
    path = "/add_report",
    tag = crate::MAIN_TAG,
    summary = "Add report",
    responses(
        (status = 200, description = "Report added!", body=Uuid),
        (status = 409, description = "Schema already exist"),
    )
)]
async fn role_secured_route(
    State(app): State<AppState>,
    Json(r): Json<AddReport>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    let report = ActiveReports { 
        check_date: Set(r.check_date),
        report_date: Set(r.report_date),
        uuid: Set(r.uuid),
        project_schedule_item: Set(r.project_schedule_item),
        status: Set(r.status) 
    };
    let result = app.orm.reports().save(report, orm::prelude::SaveMode::Insert).await.into_app_err()?;
    
    let Some(v) = result else {
        return Ok((StatusCode::CONFLICT).into_response());
    };

    Ok((StatusCode::OK, Json(v.uuid)).into_response())
   
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct AddReport{
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    uuid: uuid::Uuid,
    #[schema(example="2023-8-16")]
    #[serde(skip_serializing_if = "Option::is_none")]
    check_date: Option<chrono::NaiveDate>,
    #[schema(example="2023-8-17")]
    report_date: chrono::NaiveDate,
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    project_schedule_item: uuid::Uuid,
    #[schema(example=3)]
    status: i32,
}