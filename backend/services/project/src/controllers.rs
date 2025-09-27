use auth_jwt::structs::AccessTokenPayload;
use axum::{Extension, Json};
use axum::{extract::State, response::Response};
use schema::prelude::*;
use shared::prelude::*;

use crate::AppState;
use crate::entities::*;

#[utoipa::path(
    post,
    path = "/get-project",
    tag = crate::MAIN_TAG,
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
    Json(r): Json<GetProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().get_project(r).await;
}

#[utoipa::path(
    post,
    path = "/create-project",
    tag = crate::MAIN_TAG,
    summary = "Create project. Only users with SSK role can access it.",
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
    path = "/update-project",
    tag = crate::MAIN_TAG,
    summary = "Update project.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Project created.", body = Project),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_update_project(
    State(state): State<AppState>,
    Json(r): Json<UpdateProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().update_project(r).await;
}

#[utoipa::path(
    post,
    path = "/activate-project",
    tag = crate::MAIN_TAG,
    summary = "Activate project.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Project Activated.", body = Project),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_activate_project(
    State(state): State<AppState>,
    Json(r): Json<ActivateProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().activate_project(r).await;
}

#[utoipa::path(
    post,
    path = "/add-iko-to-project",
    tag = crate::MAIN_TAG,
    summary = "Add IKO into project.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "IKO added into project.", body = IkoRelationship),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_add_iko_to_project(
    State(state): State<AppState>,
    Json(r): Json<AddIkoToProjectRequest>,
) -> Result<Response, AppErr> {
    return state.project_service().add_iko_to_project(r).await;
}

#[utoipa::path(
    post,
    path = "/create-project-schedule",
    tag = crate::MAIN_TAG,
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
    Extension(payload) : Extension<AccessTokenPayload>,
    Json(r): Json<CreateProjectScheduleRequest>,
) -> Result<Response, AppErr> {
    return state
        .project_schedule_service()
        .create_project_schedule(r, payload)
        .await;
}

#[utoipa::path(
    post,
    path = "/add-work-to-schedule-request",
    tag = crate::MAIN_TAG,
    summary = "Add work to schedule.",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "work was added into schedule.", body = ProjectScheduleItems),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
//,Extension(payload) : Extension<AccessTokenPayload>
pub async fn handle_add_work_to_schedule(
    State(state): State<AppState>,
    Extension(payload) : Extension<AccessTokenPayload>,
    Json(r): Json<AddWorkToScheduleRequest>,
) -> Result<Response, AppErr> {
    return state
        .project_schedule_service()
        .add_work_to_schedule(r, payload)
        .await;
}

#[utoipa::path(
    post,
    path = "/update-work-schedule",
    tag = crate::MAIN_TAG,
    summary = "Update single work in schedule",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "single work in schedule was updated.", body = ProjectScheduleItems),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_update_works_in_schedule(
    State(state): State<AppState>,
    Extension(payload) : Extension<AccessTokenPayload>,
    Json(r): Json<UpdateWorkScheduleRequest>,
) -> Result<Response, AppErr> {
    return state
        .project_schedule_service()
        .update_works_in_schedule(r, payload)
        .await;
}

#[utoipa::path(
    post,
    path = "/update-works-in-schedule",
    tag = crate::MAIN_TAG,
    summary = "Update group of works in schedule",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "group of works in schedule was updated.", body = ProjectScheduleItems),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_update_work_in_schedule(
    State(state): State<AppState>,
    Extension(payload) : Extension<AccessTokenPayload>,
    Json(r): Json<UpdateWorksInScheduleRequest>,
) -> Result<Response, AppErr> {
    return state
        .project_schedule_service()
        .update_work_in_schedule(r, payload)
        .await;
}

#[utoipa::path(
    post,
    path = "/get-project-schedule",
    tag = crate::MAIN_TAG,
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
    tag = crate::MAIN_TAG,
    summary = "create work category",
    security(("bearer_access" = [])),
    responses(
        (status = 200, description = "Work category are successfully created", body = CreateProjectRequest,
            example = json!({"title": "some title", "kpgz": 638862539})
        ),
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
    tag = crate::MAIN_TAG,
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
    tag = crate::MAIN_TAG,
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
    post,
    path = "/works/save",
    tag = crate::MAIN_TAG,
    summary = "save work using work_category_uuid and title",
    security(("bearer_access" = [])),
    responses (
        (status = 200, description = "work successfully saved", body = SaveWorkResponse),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_save_work(State(state) : State<AppState>, Json(r): Json<CreateUpdateWorkRequest>) -> Result<Response, AppErr> {
    return state.work_service().save_work(r).await;
}

#[utoipa::path(
    post,
    path = "/works/get",
    tag = crate::MAIN_TAG,
    summary = "get work using work_category_uuid",
    security(("bearer_access" = [])),
    responses (
        (status = 200, description = "works list by work_category_uuid", body = GetWorksByCategoryResponse),
        (status = 500, description = "Internal server error."),
        (status = 401, description = "Unauthorized"),
    )
)]
pub async fn handle_get_works_by_category(State(state) : State<AppState>, Json(r) : Json<GetWorksByCategoryRequest>) -> Result<Response, AppErr> {
    return state.work_service().get_works_by_category(r).await;
}

#[utoipa::path(
    get,
    path = "/statuses/get",
    tag = crate::MAIN_TAG,
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