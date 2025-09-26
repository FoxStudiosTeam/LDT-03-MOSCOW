use std::collections::HashMap;

use axum::{Json, extract::{Path, Query, State}, http::StatusCode, response::{IntoResponse, Response}};
use orm::prelude::Optional::{NotSet, Set};
use serde::{Deserialize};
use shared::prelude::{AppErr, IntoAppErr};
use tracing::info;
use utoipa::IntoParams;
use utoipa_axum::{router::OpenApiRouter, routes};
use schema::prelude::*;
use uuid::Uuid;
use crate::AppState;

pub fn make_router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(
            add_report,
            get_report_statuses
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
        .routes(routes!(
            get_reports
        ))
        .with_state(state)
}

#[utoipa::path(
    get,
    path = "/get_statuses",
    tag = crate::MAIN_TAG,
    summary = "Get report statuses",
    responses(
        (status = 200, description = "Statuses fetched", body=ReportStatuses)
    )
)]
async fn get_report_statuses(
    State(app): State<AppState>,
) -> Result<Response, AppErr> {
    let result = app.orm.report_statuses().select("").fetch().await?;
    Ok((StatusCode::OK, Json(result)).into_response())
}

//-----ADD REPORT-----

#[utoipa::path(
    post,
    path = "/create_report",
    tag = crate::MAIN_TAG,
    summary = "Add report",
    responses(
        (status = 200, description = "Report added!", body=Reports),
        (status = 409, description = "Schema already exist"),
    )
)]
async fn add_report(
    State(app): State<AppState>,
    Json(r): Json<AddReport>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    app.orm.project_schedule_items().select_by_pk(&r.project_schedule_item).await?
    .ok_or_else(|| AppErr::default().with_status(StatusCode::BAD_REQUEST).with_err_response("Project schedule item not found"))?;
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
    Ok((StatusCode::OK, Json(v)).into_response())
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
    params(ReportRequest),
    responses(
        (status = 200, description = "Report deleted!", body = DeleteResponse),
        (status = 404, description = "Report not found", body = ErrorResponse),
    )
)]
async fn delete_report(
    State(app): State<AppState>,
    Query(ReportRequest{report_id}): Query<ReportRequest>,
) -> Result<Response, AppErr> {
    info!("Deleting report with UUID: {}", report_id);
    
    let result = app.orm.reports().delete_by_pk(&report_id).await.into_app_err()?;
    
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
    path = "/get_report",
    tag = crate::MAIN_TAG,
    params(ReportRequest),
    summary = "Get report",
    responses(
        (status = 200, description = "Report found", body = Reports),
        (status = 404, description = "Report not found", body = ErrorResponse),
    )
)]
async fn get_report(
    State(app): State<AppState>,
    Query(r): Query<ReportRequest>,
) -> Result<Response, AppErr> {
    info!("Fetching report with UUID: {}", r.report_id);
    let rows = sqlx::query_as::<_, ReportWithAttachmentsRecord>("
        SELECT re.*, 
        a.uuid AS attachment_uuid,
        a.original_filename,
        a.base_entity_uuid,
        a.file_uuid,
        a.content_type
        FROM norm.reports re
        LEFT JOIN attachment.attachments a ON a.base_entity_uuid = re.uuid
        WHERE re.uuid = $1;
    ").bind(r.report_id).fetch_all(app.orm.get_executor()).await.into_app_err()?;
    if rows.is_empty() {return Ok((StatusCode::NOT_FOUND, Json(ErrorResponse { message: "Report not found".to_string() })).into_response())};
    let mut hm = HashMap::new();

    for row in rows {
        let a = row.attachments.into_attachments();
        let e = &mut hm.entry(row.report.uuid.clone())
            .or_insert_with(|| ReportWithAttachments {
                attachments: vec![], 
                report: row.report
            })
            .attachments;
        let Some(a) = a else {continue};
        e.push(a);  
    }
    let v = hm.into_values().collect::<Vec<_>>();
    Ok((StatusCode::OK, Json(v)).into_response())
}

#[derive(serde::Deserialize, utoipa::ToSchema, IntoParams)]
pub struct ReportRequest {
    #[schema(example=Uuid::new_v4)]
    pub report_id: uuid::Uuid,
}

//-----UPDATE REPORT-----

#[utoipa::path(
    put,
    path = "/upd_report",
    tag = crate::MAIN_TAG,
    summary = "Update report",
    request_body = UpdateReport,
    responses(
        (status = 200, description = "Report updated", body = Reports),
        (status = 404, description = "Report not found", body = ErrorResponse),
    )
)]
async fn update_report(
    State(app): State<AppState>,
    Json(r): Json<UpdateReport>,
) -> Result<Response, AppErr> {
    info!("Updating report with UUID: {}", r.uuid);

    let existing = app.orm.reports().select_by_pk(&r.uuid).await.into_app_err()?;
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
    uuid: Set(r.uuid),
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
        Json(updated),
    )
        .into_response())
}

//-----GET REPORTS-----

#[derive(serde::Deserialize, utoipa::ToSchema, Debug)]
pub struct UpdateReport { 
    #[schema(example=Uuid::new_v4)]
    pub uuid: Uuid,

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


#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct ReportWithAttachments {
    report: Reports,
    attachments: Vec<Attachments>,
}

#[derive(sqlx::FromRow)]
pub struct ReportWithAttachmentsRecord {
    #[sqlx(flatten)]
    report: Reports,
    #[sqlx(flatten)]
    attachments: OptionalAttachments,
}



#[derive(sqlx::FromRow, Default, Debug)]
pub struct OptionalAttachments {
    pub original_filename: Option<String>,
    pub attachment_uuid: Option<uuid::Uuid>,
    pub base_entity_uuid: Option<uuid::Uuid>,
    pub file_uuid: Option<uuid::Uuid>,
    pub content_type: Option<String>,
}

impl OptionalAttachments {
    fn into_attachments(self) -> Option<Attachments> {
        Some(Attachments {
            original_filename: self.original_filename?,
            uuid: self.attachment_uuid?,
            base_entity_uuid: self.base_entity_uuid?,
            file_uuid: self.file_uuid?,
            content_type: self.content_type,
        })
    }
}



#[utoipa::path(
    get,
    path = "/get_reports",
    tag = crate::MAIN_TAG,
    summary = "Get reports",
    params(ReportsRequest),
    responses(
        (status = 200, description = "Reports found", body = Vec<ReportWithAttachments>),
        (status = 400, description = "Project schedule ton found", body=ErrorResponse)
    )
)]
async fn get_reports(
    State(app): State<AppState>,
    Query(r): Query<ReportsRequest>,
) -> Result<Response, AppErr> {
    info!("Fetching report with UUID: {}", r.project_schedule_item);


    let rows = sqlx::query_as::<_, ReportWithAttachmentsRecord>("
        SELECT re.*, 
        a.uuid AS attachment_uuid,
        a.original_filename,
        a.base_entity_uuid,
        a.file_uuid,
        a.content_type
        FROM norm.reports re
        LEFT JOIN attachment.attachments a ON a.base_entity_uuid = re.uuid
        WHERE re.project_schedule_item = $1;
    ").bind(r.project_schedule_item).fetch_all(app.orm.get_executor()).await.into_app_err()?;

    let mut hm = HashMap::new();

    for row in rows {
        let a = row.attachments.into_attachments();
        let e = &mut hm.entry(row.report.uuid.clone())
            .or_insert_with(|| ReportWithAttachments {
                attachments: vec![], 
                report: row.report
            })
            .attachments;
        let Some(a) = a else {continue};
        e.push(a);  
    }
    let v = hm.into_values().collect::<Vec<_>>();
    Ok((StatusCode::OK, Json(v)).into_response())
}

#[derive(serde::Deserialize, utoipa::ToSchema, IntoParams)]
pub struct ReportsRequest {
    #[schema(example=Uuid::new_v4)]
    pub project_schedule_item: uuid::Uuid,
}