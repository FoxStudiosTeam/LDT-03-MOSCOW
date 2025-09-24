use std::sync::Arc;

use async_trait::async_trait;
use axum::response::IntoResponse;
use axum::{Json, http::StatusCode, response::Response};
use orm::prelude::Optional::Set;
use schema::prelude::{ActiveProject, OrmProject};
use shared::prelude::IntoAppErr;
use shared::prelude::{AppErr};
use uuid::Uuid;

use crate::AppState;
use crate::entities::*;

#[async_trait]
pub trait IProjectService: Send + Sync {
    async fn get_project(&self, r: GetProjectRequest) -> Result<Response, AppErr>;
    async fn create_project(&self, r: CreateProjectRequest) -> Result<Response, AppErr>;
    async fn update_project(&self, r: UpdateProjectRequest) -> Result<Response, AppErr>;
}

#[derive(Clone)]
struct ProjectService {
    state: AppState,
}

#[async_trait]
impl IProjectService for ProjectService {
    async fn get_project(&self, r: GetProjectRequest) -> Result<Response, AppErr> {
        let (offset, limit) = r.pagination.map(|p| (p.offset, p.limit)).unwrap_or((0, 0));

        let address = r.address.map(|addr| (addr)).ok_or(
            AppErr::default()
                .with_err_response("address is empty")
                .with_status(StatusCode::BAD_REQUEST),
        )?;

        let row = self
            .state
            .orm()
            .project()
            .select("select * from project.project p where p.address like $1 offset $2 limit $3")
            .bind(format!("%{}%", address))
            .bind(offset)
            .bind(limit)
            .fetch()
            .await
            .into_app_err()?;

        let total: (i64,) = sqlx::query_as::<_, (i64,)>(
            "SELECT COUNT(*) FROM project.project WHERE address like $1",
        )
        .bind(format!("%{}%", address))
        .fetch_one(self.state.orm().get_executor())
        .await
        .into_app_err()?;

        let result = GetProjectResult {
            result: row,
            total: total.0,
        };

        return Ok((StatusCode::OK, Json(result)).into_response());
    }

    async fn create_project(&self, r: CreateProjectRequest) -> Result<Response, AppErr> {
        let mut project = ActiveProject::default();

        let addr = r.address.map(|addr| (addr)).ok_or(
            AppErr::default()
                .with_err_response("address is empty")
                .with_status(StatusCode::BAD_REQUEST),
        )?;
        project.address = Set(addr);

        let polygon = r
            .polygon
            .map(|poly| serde_json::from_str(&poly).into_app_err())
            .ok_or(
                AppErr::default()
                    .with_err_response("polygon is uncorrected value")
                    .with_status(StatusCode::BAD_REQUEST),
            )?;
        project.polygon = Set(polygon?);

        let ssk = r.ssk.and_then(|sk| uuid::Uuid::parse_str(&sk).ok()).ok_or(
            AppErr::default()
                .with_err_response("ssk is invalid uuid")
                .with_status(StatusCode::BAD_REQUEST),
        )?;
        project.ssk = Set(Some(ssk));

        project.status = Set(0);

        let res = self
            .state
            .orm()
            .project()
            .save(project, orm::prelude::SaveMode::Insert)
            .await
            .into_app_err()?
            .and_then(|res| Some(res))
            .ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;
        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn update_project(&self, r: UpdateProjectRequest) -> Result<Response, AppErr> {
        let mut project = ActiveProject::default();

        r.foreman.and_then(|foreman| {
            Some(uuid::Uuid::parse_str(&foreman).and_then(|f| Ok(project.foreman = Set(Some(f)))))
        });

        match r.status {
            Some(raw_status) => {
                match ProjectStatus::try_from(raw_status) {
                    Ok(
                        s @ ProjectStatus::New
                        | s @ ProjectStatus::InActive
                        | s @ ProjectStatus::Suspend
                        | s @ ProjectStatus::Normal
                        | s @ ProjectStatus::LowPunishment
                        | s @ ProjectStatus::NormalPunishment
                        | s @ ProjectStatus::HighPunishment
                        | s @ ProjectStatus::SomeWarnings,
                    ) => Some(s),
                    Err(_) => {
                        return Err(AppErr::default()
                            .with_err_response("unsupported status number")
                            .with_status(StatusCode::BAD_REQUEST));
                    }
                }
            }
            None => None,
        }.and_then(|status| Some(project.status = Set(status as i32)));

        Uuid::parse_str(&r.uuid).and_then(|guid| Ok(project.uuid = Set(guid))).map_err(|e| AppErr::default().with_err_response(e.to_string().as_str()))?;

        let res = self.state.orm().project().save(project, orm::prelude::SaveMode::Update).await.into_app_err()?.and_then(|res| Some(res))
            .ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;

        return Ok((StatusCode::OK, Json(res)).into_response());   
    }
}

pub fn new_project_service(state: AppState) -> Arc<dyn IProjectService> {
    return Arc::new(ProjectService { state });
}
