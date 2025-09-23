
use axum::Json;
use axum::{extract::State, response::Response};
use shared::prelude::AppErr;

use crate::{AppState};
use crate::entities::{GetProjectRequest};

#[utoipa::path(
    post,
    path = "/create_project",
    tag = crate::MAIN_TAG,
    summary = "Create project. Only users with Customer role can access it.",
    responses(
        (status = 200, description = "Project created."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_project(State(state) : State<AppState>, Json(r) : Json<GetProjectRequest>) -> Result<Response, AppErr> {
    return state.project_service().get_project(r).await
}