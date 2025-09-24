
use axum::Json;
use axum::{extract::State, response::Response};
use shared::prelude::AppErr;

use crate::{AppState};
use crate::entities::{CreateProjectRequest, GetProjectRequest, UpdateProjectRequest};

#[utoipa::path(
    post,
    path = "/get_project",
    tag = crate::MAIN_TAG,
    summary = "Get project.",
    responses(
        (status = 200, description = "Project finded."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_project(State(state) : State<AppState>, Json(r) : Json<GetProjectRequest>) -> Result<Response, AppErr> {
    return state.project_service().get_project(r).await
}

#[utoipa::path(
    post,
    path = "/create_project",
    tag = crate::MAIN_TAG,
    summary = "Create project. Only users with SSK role can access it.",
    responses(
        (status = 200, description = "Project created."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_create_project(State(state) : State<AppState>, Json(r) : Json<CreateProjectRequest>) -> Result<Response, AppErr> {
    return state.project_service().create_project(r).await
}

#[utoipa::path(
    post,
    path = "/update_project",
    tag = crate::MAIN_TAG,
    summary = "Update project.",
    responses(
        (status = 200, description = "Project created."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_update_project(State(state) : State<AppState>, Json(r) : Json<UpdateProjectRequest>) -> Result<Response, AppErr> {
    return state.project_service().update_project(r).await
}