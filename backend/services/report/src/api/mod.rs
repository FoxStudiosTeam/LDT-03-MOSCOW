use std::ops::Add;

use axum::{extract::{Path, State}, http::StatusCode, response::{IntoResponse, Response}, Json};
use orm::prelude::Optional::{NotSet, Set};
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
            add_report
        ))
        .routes(routes!(
            delete_report
        ))
        .routes(routes!(
            get_report
        ))
        .routes(routes!(
            update_report
        ))
        .with_state(state)
}
//-----ADD REPORT-----

#[utoipa::path(
    post,
    path = "/report",
    tag = crate::MAIN_TAG,
    summary = "Add report",
    responses(
        (status = 200, description = "Report added!", body=Uuid),
        (status = 409, description = "Schema already exist"),
    )
)]
async fn add_report(
    State(app): State<AppState>,
    Json(r): Json<AddReport>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    let report = ActiveReports { 
        check_date: Set(r.check_date),
        report_date: Set(r.report_date),
        project_schedule_item: Set(r.project_schedule_item),
        status: Set(r.status),
        uuid: NotSet,
    };
    let result = app.orm.reports().save(report, orm::prelude::SaveMode::Insert).await.into_app_err()?;
    let Some(v) = result else {
        return Ok((StatusCode::CONFLICT).into_response());
    };
    Ok((StatusCode::OK, Json(v.uuid)).into_response())
}
#[derive(utoipa::ToSchema, Deserialize, Debug)]
pub struct AddReport{
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

//-----DELETE REPORT-----

#[utoipa::path(
    delete,
    path = "/report/{uuid}",
    tag = crate::MAIN_TAG,
    summary = "Delete report",
    params(
        ("uuid" = Uuid, Path, description = "UUID of the report to delete")
    ),
    responses(
        (status = 200, description = "Report deleted!", body = DeleteResponse),
        (status = 404, description = "Report not found", body = ErrorResponse),
    )
)]
async fn delete_report(
    State(app): State<AppState>,
    Path(uuid): Path<uuid::Uuid>,
) -> Result<Response, AppErr> {
    info!("Deleting report with UUID: {}", uuid);
    
    let result = app.orm.reports().delete_by_pk(&uuid).await.into_app_err()?;
    
    match result {
        Some(report) => Ok((
            StatusCode::OK,
            Json(DeleteResponse {
                message: "Report deleted successfully".to_string(),
                uuid: report.uuid,
            }),
        )
            .into_response()),
        None => Ok((
            StatusCode::NOT_FOUND,
            Json(ErrorResponse {
                message: "Report not found".to_string(),
            }),
        )
            .into_response()),
    }
}

#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct DeleteResponse {
    pub message: String,
    pub uuid: uuid::Uuid,
}

#[derive(serde::Serialize, utoipa::ToSchema)]

pub struct ErrorResponse {
    pub message: String,
}

//-----GET REPORT-----

#[utoipa::path(
    get,
    path = "/report/{uuid}",
    tag = crate::MAIN_TAG,
    summary = "Get report",
    params(
        ("uuid" = Uuid, Path, description = "UUID of the report to fetch")
    ),
    responses(
        (status = 200, description = "Report found", body = ReportResponse),
        (status = 404, description = "Report not found", body = ErrorResponse),
    )
)]
async fn get_report(
    State(app): State<AppState>,
    Path(uuid): Path<uuid::Uuid>,
) -> Result<Response, AppErr> {
    info!("Fetching report with UUID: {}", uuid);

    let result = app.orm.reports().select_by_pk(&uuid).await.into_app_err()?;

    match result {
        Some(report) => Ok((
            StatusCode::OK,
            Json(ReportResponse {
                uuid: report.uuid,
                check_date: report.check_date,
                report_date: report.report_date,
                project_schedule_item: report.project_schedule_item,
                status: report.status,
            }),
        )
            .into_response()),
        None => Ok((
            StatusCode::NOT_FOUND,
            Json(ErrorResponse {
                message: "Report not found".to_string(),
            }),
        )
            .into_response()),
    }
}

#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct ReportResponse {
    pub uuid: uuid::Uuid,
    pub check_date: Option<chrono::NaiveDate>,
    pub report_date: chrono::NaiveDate,
    pub project_schedule_item: uuid::Uuid,
    pub status: i32,
}


//-----UPDATE REPORT-----

#[utoipa::path(
    put,
    path = "/report/{uuid}",
    tag = crate::MAIN_TAG,
    summary = "Update report",
    params(
        ("uuid" = Uuid, Path, description = "UUID of the report to update")
    ),
    request_body = UpdateReport,
    responses(
        (status = 200, description = "Report updated", body = ReportResponse),
        (status = 404, description = "Report not found", body = ErrorResponse),
    )
)]
async fn update_report(
    State(app): State<AppState>,
    Path(uuid): Path<uuid::Uuid>,
    Json(r): Json<UpdateReport>,
) -> Result<Response, AppErr> {
    info!("Updating report with UUID: {}", uuid);

    let existing = app.orm.reports().select_by_pk(&uuid).await.into_app_err()?;
    if existing.is_none() {
        return Ok((
            StatusCode::NOT_FOUND,
            Json(ErrorResponse {
                message: "Report not found".to_string(),
            }),
        )
            .into_response());
    }

    let report = ActiveReports {
    uuid: Set(uuid),
    check_date: Set(r.check_date), 
    report_date: r.report_date.map(Set).unwrap_or(NotSet),
    project_schedule_item: r.project_schedule_item.map(Set).unwrap_or(NotSet),
    status: r.status.map(Set).unwrap_or(NotSet),
    };

    let updated = app
        .orm
        .reports()
        .save(report, orm::prelude::SaveMode::Update)
        .await
        .into_app_err()?;

    let Some(updated) = updated else {
        return Ok((
            StatusCode::NOT_FOUND,
            Json(ErrorResponse {
                message: "Report not found".to_string(),
            }),
        )
            .into_response());
    };

    Ok((
        StatusCode::OK,
        Json(ReportResponse {
            uuid: updated.uuid,
            check_date: updated.check_date,
            report_date: updated.report_date,
            project_schedule_item: updated.project_schedule_item,
            status: updated.status,
        }),
    )
        .into_response())
}

#[derive(serde::Deserialize, utoipa::ToSchema, Debug)]
pub struct UpdateReport {
    #[schema(example = "2023-08-16")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub check_date: Option<chrono::NaiveDate>,

    #[schema(example = "2023-08-17")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub report_date: Option<chrono::NaiveDate>,

    #[schema(example = "a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub project_schedule_item: Option<uuid::Uuid>,

    #[schema(example = 3)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub status: Option<i32>,
}
