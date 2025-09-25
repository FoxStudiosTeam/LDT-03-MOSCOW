
use axum::Json;
use axum::{extract::State, response::Response};
use shared::prelude::AppErr;

use crate::{AppState};
use crate::entities::{ActivateProjectRequest, AddIkoToProjectRequest, AddWorkToScheduleRequest, CreateProjectRequest, CreateProjectScheduleRequest, GetProjectRequest, GetProjectScheduleRequest, UpdateProjectRequest, UpdateWorkScheduleRequest, UpdateWorksInScheduleRequest};

#[utoipa::path(
    post,
    path = "/get-project",
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
    path = "/create-project",
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
    path = "/update-project",
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

#[utoipa::path(
    post,
    path = "/activate-project",
    tag = crate::MAIN_TAG,
    summary = "Activate project.",
    responses(
        (status = 200, description = "Project Activated."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_activate_project(State(state) : State<AppState>, Json(r) : Json<ActivateProjectRequest>) -> Result<Response, AppErr> {
    return state.project_service().activate_project(r).await
}

#[utoipa::path(
    post,
    path = "/add-iko-to-project",
    tag = crate::MAIN_TAG,
    summary = "Add IKO into project.",
    responses(
        (status = 200, description = "IKO added into project."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_add_iko_to_project(State(state) : State<AppState>, Json(r) : Json<AddIkoToProjectRequest>) -> Result<Response, AppErr> {
    return state.project_service().add_iko_to_project(r).await
}

#[utoipa::path(
    post,
    path = "/create-project-schedule",
    tag = crate::MAIN_TAG,
    summary = "Create project schedule.",
    responses(
        (status = 200, description = "project schedule was created in project."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_create_project_schedule(State(state) : State<AppState>, Json(r) : Json<CreateProjectScheduleRequest>) -> Result<Response, AppErr> {
    return state.project_schedule_service().create_project_schedule(r).await
}

#[utoipa::path(
    post,
    path = "/add-work-to-schedule-request",
    tag = crate::MAIN_TAG,
    summary = "Add work to schedule.",
    responses(
        (status = 200, description = "work was added into schedule."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_add_work_to_schedule(State(state) : State<AppState>, Json(r) : Json<AddWorkToScheduleRequest>) -> Result<Response, AppErr> {
    return state.project_schedule_service().add_work_to_schedule(r).await
}

#[utoipa::path(
    post,
    path = "/update-work-schedule",
    tag = crate::MAIN_TAG,
    summary = "Update single work in schedule",
    responses(
        (status = 200, description = "single work in schedule was updated."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_update_work_schedule(State(state) : State<AppState>, Json(r) : Json<UpdateWorkScheduleRequest>) -> Result<Response, AppErr> {
    return state.project_schedule_service().update_work_schedule(r).await
}

#[utoipa::path(
    post,
    path = "/update-works-in-schedule",
    tag = crate::MAIN_TAG,
    summary = "Update group of works in schedule",
    responses(
        (status = 200, description = "group of works in schedule was updated."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_update_works_in_schedule(State(state) : State<AppState>, Json(r) : Json<UpdateWorksInScheduleRequest>) -> Result<Response, AppErr> {
    return state.project_schedule_service().update_works_in_schedule(r).await
}

#[utoipa::path(
    post,
    path = "/get-project-schedule",
    tag = crate::MAIN_TAG,
    summary = "Get project schdule by uuid.",
    responses(
        (status = 200, description = "Get project schdule by uuid."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_project_schedule(State(state) : State<AppState>, Json(r) : Json<GetProjectScheduleRequest>) -> Result<Response, AppErr> {
    return state.project_schedule_service().get_project_schedule(r).await
}
