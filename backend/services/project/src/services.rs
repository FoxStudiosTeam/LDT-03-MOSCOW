use std::sync::Arc;

use async_trait::async_trait;
use axum::response::IntoResponse;
use axum::{Json, http::StatusCode, response::Response};
use orm::prelude::Optional::{Set};
use schema::prelude::{ActiveProject, OrmProject, Project};
use shared::prelude::{AppErr, ErrorWrapper};
use shared::prelude::IntoAppErr;

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

        let address = r.address.map(|addr| (addr)).unwrap_or("".to_string());

        let mut row: Vec<Project> = Vec::new();

        match self
            .state
            .orm()
            .project()
            .select("select * from project.project p where p.address = $1 offset $2 limit $3")
            .bind(&address)
            .bind(offset)
            .bind(limit)
            .fetch()
            .await
            .into_app_err()
        {
            Ok(res) => {
                row = res;
            }
            Err(e) => return Err(e.with_status(StatusCode::INTERNAL_SERVER_ERROR)),
        }

        let total: (i32,) =
            sqlx::query_as::<_, (i32,)>("SELECT COUNT(*) FROM project.project WHERE address = $1")
                .bind(address)
                .fetch_one(self.state.orm().get_executor())
                .await?;

        let result = GetProjectResult {
            result: row,
            total: total.0,
        };
        return Ok((StatusCode::OK, Json(result)).into_response());
    }

    async fn create_project(&self, r: CreateProjectRequest) -> Result<Response, AppErr> {
        let mut project = ActiveProject::default();
        project.uuid = Set(uuid::Uuid::new_v4());

        if let Some(addr) = r.address {
            if addr.is_empty() {
                return Err(AppErr::default().with_response(ErrorWrapper::new("address is empty".to_string()).into_response())
                    .with_status(StatusCode::BAD_REQUEST));
            }
            project.address = Set(addr);
        }

        if let Some(polygon) = r.polygon {
            if polygon.is_empty() {
                return Err(AppErr::default().with_response(ErrorWrapper::new("polygon is empty".to_string()).into_response())
                    .with_status(StatusCode::BAD_REQUEST));
            }
            let raw = serde_json::from_str(&polygon).into_app_err();
            match raw {
                Ok(json_value) => {
                    project.polygon = Set(json_value);
                }
                Err(_) => {
                    return Err(AppErr::default().with_response(ErrorWrapper::new("polygon is incorrect".to_string()).into_response())
                        .with_status(StatusCode::BAD_REQUEST));
                }
            }
        }

        match r.ssk {
            Some(ssk) => {
                if ssk.is_empty() {
                    return Err(AppErr::default().with_response(ErrorWrapper::new("ssk field is empty".to_string()).into_response()));
                }

                match uuid::Uuid::parse_str(&ssk).into_app_err() {
                    Ok(id) => project.uuid = Set(id),
                    Err(er) => {
                        return Err(er.with_status(StatusCode::BAD_REQUEST));
                    }
                }
            }
            None => {
                return Err(AppErr::default().with_response(ErrorWrapper::new("ssk field is empty".to_string()).into_response()));
            }
        }

        project.status = Set(0);

        match self
            .state
            .orm()
            .project()
            .save(project, orm::prelude::SaveMode::Insert)
            .await
            .into_app_err()
        {
            Ok(res) => {
                if let Some(project) = res {
                    return Ok((StatusCode::OK, Json(project)).into_response());
                }
                return Err(AppErr::default().with_status(StatusCode::INTERNAL_SERVER_ERROR).with_response(ErrorWrapper::new("empty result while create project".to_string()).into_response()));
            }
            Err(err) => return Err(err.with_status(StatusCode::INTERNAL_SERVER_ERROR).with_response(ErrorWrapper::new("some error while create project".to_string()).into_response())),
        }
    }

    async fn update_project(&self, r: UpdateProjectRequest) -> Result<Response, AppErr> {
        let mut project = ActiveProject::default();

        if let Some(foreman) = r.foreman {
            match uuid::Uuid::parse_str(&foreman).into_app_err() {
                Ok(forman_uuid) => {
                    project.foreman = Set(Some(forman_uuid));
                }
                Err(er) => {
                    return Err(er.with_status(StatusCode::BAD_REQUEST).with_response(ErrorWrapper::new("foreman is empty".to_string()).into_response()));
                }
            }
        }

        if let Some(st) = r.status {
            ProjectStatus::try_from(st)
                .ok()
                .filter(|s| {
                    matches!(
                        s,
                        ProjectStatus::New
                            | ProjectStatus::InActive
                            | ProjectStatus::Suspend
                            | ProjectStatus::Normal
                            | ProjectStatus::LowPunishment
                            | ProjectStatus::NormalPunishment
                            | ProjectStatus::HighPunishment
                            | ProjectStatus::SomeWarnings
                    )
                })
                .ok_or_else(|| {
                    AppErr::default().with_response(ErrorWrapper::new("unsupported status number".to_string()).into_response())
                        .with_status(StatusCode::BAD_REQUEST)
                })?;
            project.status = Set(st);
        }

        match self
            .state
            .orm()
            .project()
            .save(project, orm::prelude::SaveMode::Update)
            .await
            .into_app_err()
        {
            Ok(res) => {
                if let Some(project) = res {
                    return Ok((StatusCode::OK, Json(project)).into_response());
                }
                return Err(AppErr::default().with_status(StatusCode::INTERNAL_SERVER_ERROR));
            }
            Err(err) => return Err(err.with_status(StatusCode::INTERNAL_SERVER_ERROR)),
        }
    }
}

pub fn new_project_service(state: AppState) -> Arc<dyn IProjectService> {
    return Arc::new(ProjectService { state });
}
