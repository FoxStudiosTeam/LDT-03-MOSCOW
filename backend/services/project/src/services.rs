use std::sync::Arc;

use async_trait::async_trait;
use axum::{http::StatusCode, response::Response, Json};
use orm::prelude::Orm;
use shared::prelude::{AppErr};
use sqlx::{Pool, Postgres};
use schema::prelude::{Project};
use axum::response::IntoResponse;

use crate::AppState;
use crate::entities::GetProjectRequest;

#[async_trait]
pub trait IProjectService : Send + Sync{
    async fn get_project(&self,r: GetProjectRequest) -> Result<Response, AppErr>;
}

#[derive(Clone)]
struct ProjectService {
    state : AppState
}

#[async_trait]
impl IProjectService for ProjectService {
    async fn get_project(&self,r : GetProjectRequest)-> Result<Response, AppErr> {
        let mut project = Project{address: r.address , foreman: None, polygon: None, ssk: None, status: 0, uuid: uuid::Uuid::new_v4()};
        let resp = (StatusCode::OK, Json(project)).into_response();
        Ok(resp)
    }
}

pub fn new_project_service(state : AppState) -> Arc<dyn IProjectService> {
    return Arc::new(ProjectService{state})
}