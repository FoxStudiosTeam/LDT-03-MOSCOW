use auth_jwt::structs::AccessTokenPayload;
use axum::extract::Query;
use axum::{Extension, Json};
use axum::{extract::State, response::Response};
use schema::prelude::*;
use shared::prelude::*;

use crate::AppState;
use crate::entities::*;

#[utoipa::path(
    post,
    path = "/get-inspector-projects",
    tag = crate::ANY_TAG,
    summary = "Get projects related to inspector",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Project found.", body = GetProjectWithAttachmentResult),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_inspector_projects(
    State(state): State<AppState>,
    Extension(payload): Extension<AccessTokenPayload>,
    Json(r): Json<GetProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().get_inspector_projects(r, payload).await;
}

#[utoipa::path(
    post,
    path = "/get-project",
    tag = crate::ANY_TAG,
    summary = "Get project.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Project found.", body = GetProjectWithAttachmentResult),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_project(
    State(state): State<AppState>,
    Extension(payload): Extension<AccessTokenPayload>,
    Json(r): Json<GetProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().get_project(r, payload).await;
}

#[utoipa::path(
    post,
    path = "/create-project",
    tag = crate::CUSTOMER_TAG,
    summary = "Create project.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Project created.", body = Project),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_create_project(
    State(state): State<AppState>,
    Extension(payload): Extension<AccessTokenPayload>,
    Json(r): Json<CreateProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().create_project(r, payload).await;
}

#[utoipa::path(
    post,
    path = "/set-foreman",
    tag = crate::CUSTOMER_NEW_PROJECT_TAG,
    summary = "Update project.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Project created.", body = Project),
        (status = 404, description = "Foreman not found."),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_set_project_foreman(
    State(state): State<AppState>,
    Extension(t) : Extension<AccessTokenPayload>,
    Json(r): Json<SetProjectForemanRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().set_project_foreman(r, t).await;
}

#[utoipa::path(
    put,
    path = "/activate-project",
    tag = crate::INSPECTOR_TAG,
    summary = "Activate project. Only users with IKO role can access it.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Project Activated.", body = Project),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_activate_project(
    State(state): State<AppState>,
    Extension(t) : Extension<AccessTokenPayload>,
    Json(r): Json<ProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().activate_project(r, t).await;
}

#[utoipa::path(
    post,
    path = "/add-iko-to-project",
    tag = crate::INSPECTOR_TAG,
    summary = "Add IKO into project. Called by iko itself",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "IKO added into project.", body = IkoRelationship),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_add_iko_to_project(
    State(state): State<AppState>,
    Extension(t) : Extension<AccessTokenPayload>,
    Json(r): Json<AddIkoToProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().add_iko_to_project(r, t).await;
}

#[utoipa::path(
    post,
    path = "/create-project-schedule",
    tag = crate::CUSTOMER_TAG,
    summary = "Create project schedule.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "project schedule was created in project.", body = ProjectSchedule),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_create_project_schedule(
    State(state): State<AppState>,
    Extension(t) : Extension<AccessTokenPayload>,
    Json(r): Json<CreateProjectScheduleRequest>,
) -> Result<Response, AppErr> {
    return state
        .project_schedule_service()
        .create_project_schedule(r, t)
        .await;
}


#[utoipa::path(
    post,
    path = "/update-work-schedule",
    tag = crate::CUSTOMER_TAG,
    summary = "Set subworks for schedule after init project. State must be >=Normal to use this endpoint. This endpoints check bounds for every subwork and throw error if out of bounds.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Works in schedule was updated.", body = Vec<ProjectScheduleItems>),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_update_works_in_schedule(
    State(state): State<AppState>,
    Extension(payload) : Extension<AccessTokenPayload>,
    Json(r): Json<SetWorksInScheduleRequest>,
) -> Result<Response, AppErr> {
    return state
        .project_schedule_service()
        .update_works_in_schedule(r, payload)
        .await;
}


#[utoipa::path(
    post,
    path = "/set-works-in-schedule",
    tag = crate::CUSTOMER_NEW_PROJECT_TAG,
    summary = "Set subworks for schedule (soft override - will delete every work that not presented in request, add new and update existing. Work marked as new if uuid is not set.)",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "group of works in schedule was updated.", body = Vec<ProjectScheduleItems>),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_set_works_in_schedule(
    State(state): State<AppState>,
    Extension(payload) : Extension<AccessTokenPayload>,
    Json(r): Json<SetWorksInScheduleRequest>,
) -> Result<Response, AppErr> {
    return state
        .project_schedule_service()
        .set_works_in_schedule(r, payload)
        .await;
}

#[utoipa::path(
    post,
    path = "/get-project-schedule",
    tag = crate::ANY_TAG,
    summary = "Get project schedule by uuid.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Get project schedule by uuid.", body = GetProjectScheduleResponse),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_project_schedule(
    State(state): State<AppState>,
    Extension(payload) : Extension<AccessTokenPayload>,
    Json(r): Json<GetProjectScheduleRequest>,
) -> Result<Response, AppErr> {
    return state
        .project_schedule_service()
        .get_project_schedule(r, payload)
        .await;
}

#[utoipa::path(
    post,
    path = "/create-work-category",
    tag = crate::DEV_ONLY_TAG,
    summary = "create work category",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Work category are successfully created", body = Option<WorkCategory>),
        (status = 400, description = "Kpgz id not found"),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_create_work_category(
    State(state): State<AppState>,
    Json(r): Json<CreateWorkCategoryRequest>,
) -> Result<Response, AppErr> {
    return state.work_category_service().create_work_category(r).await;
}

#[utoipa::path(
    put,
    tag = crate::DEV_ONLY_TAG,
    path = "/update-work-category",
    summary = "update one work category",
    security(("bearer_access" = [])),
    responses (
        (status = 200, description = "Update one Work Category", body = Option<WorkCategory>),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_update_work_category(
    State(state): State<AppState>,
    Json(r): Json<UpdateWorkCategoryRequest>,
) -> Result<Response, AppErr> {
    return state.work_category_service().update_work_category(r).await;
}

#[utoipa::path(
    get,
    path = "/get-work-category",
    tag = crate::GUEST_TAG,
    summary = "get work categories as vec",
    responses (
        (status = 200, description = "Work Categories as vec", body = GetWorkCategoriesResponse),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_work_categories(State(state): State<AppState>) -> Result<Response, AppErr> {
    return state.work_category_service().get_work_categories().await;
}

#[utoipa::path(
    get,
    path = "/get-kpgz-vec",
    tag = crate::GUEST_TAG,
    summary = "get kpgz dictionary as vec",
    responses (
        (status = 200, description = "kpgz dictionary as vec", body = GetKpgz),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_kpgz_vec(State(state) : State<AppState>) -> Result<Response, AppErr> {
    return state.work_category_service().get_kpgz_vec().await;
}


#[utoipa::path(
    get,
    path = "/get-measurements",
    tag = crate::GUEST_TAG,
    summary = "get measurement dictionary as vec",
    responses (
        (status = 200, description = "Measurement dictionary as vec", body = Vec<Measurements>),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_measurements(State(state) : State<AppState>) -> Result<Response, AppErr> {
    return state.work_service().get_measurements().await;
}

#[utoipa::path(
    get,
    path = "/get-statuses",
    tag = crate::GUEST_TAG,
    summary = "get project statuses",
    responses (
        (status = 200, description = "project statuses list", body = ProjectStatusesResponse),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_project_statuses(State(state) : State<AppState>) -> Result<Response, AppErr> {
    return state.project_service().get_project_statuses().await;
}


#[utoipa::path(
    put,
    path = "/project-commit",
    tag = crate::CUSTOMER_NEW_PROJECT_TAG,
    params(ProjectRequest),
    summary = "Commit project request",
    security(("bearer_access" = [])),
    responses (
        (status = 200, description = "Commited"),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn commit_project(
    State(state) : State<AppState>,
    Extension(t) : Extension<AccessTokenPayload>,
    Query(r) : Query<ProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().commit_project(r, t).await;
}

#[utoipa::path(
    delete,
    path = "/project-schedule",
    tag = crate::CUSTOMER_NEW_PROJECT_TAG,
    params(DeleteProjectScheduleRequest),
    summary = "Delete project schedule",
    security(("bearer_access" = [])),
    responses (
        (status = 200, description = "Deleted"),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn delete_project_schedule(
    State(state) : State<AppState>,
    Extension(t) : Extension<AccessTokenPayload>,
    Query(r) : Query<DeleteProjectScheduleRequest>,
) -> Result<Response, AppErr> {
    return state.project_schedule_service().delete_project_schedule(r, t).await;
}


#[utoipa::path(
    get,
    path = "/get-project_inspectors",
    tag = crate::ANY_TAG,
    summary = "get inspectors related to project",
    responses (
        (status = 200, description = "Inspector list as vec", body = GetProjectInspectorsResponse),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_project_inspectors(
    Extension(payload): Extension<AccessTokenPayload>,
    State(state) : State<AppState>,
    Json(r): Json<GetProjectInspectorsRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().get_project_inspectors(r, payload).await;
}