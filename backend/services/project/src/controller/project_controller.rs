
use axum::response::Response;
use orm::prelude::Orm;
use shared::prelude::AppErr;

use sqlx::{Pool, Postgres};
use utoipa_axum::{router::OpenApiRouter, routes};

use crate::AppState;

#[utoipa::path(
    get,
    path = "/pets/{id}",
    responses(
        (status = 200, description = "Project found successfully", body = Pet),
        (status = NOT_FOUND, description = "Project was not found")
    ),
    params(
        ("id" = u64, Path, description = "Pet database id to get Pet for"),
    )
)]
pub async fn get_projects()  -> Result<Response, AppErr>{
    todo!()
}

pub async fn create_project() -> Result<Response, AppErr> {
    todo!()
}

pub fn setup_project_routes(state : AppState<Orm<Pool<Postgres>>>) -> OpenApiRouter {
    return OpenApiRouter::new().routes(
        routes!(get_projects)
    ).with_state(state);
}