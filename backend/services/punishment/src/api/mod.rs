use utoipa_axum::{router::OpenApiRouter, routes};
use crate::AppState;

pub mod get_punishments;

pub fn make_router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(
            get_punishments::get_punishments
        ))
        .with_state(state)
}
