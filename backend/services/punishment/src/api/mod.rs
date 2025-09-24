use auth_jwt::prelude::Role;
use utoipa_axum::{router::OpenApiRouter, routes};
use crate::AppState;

pub mod get_punishments;
pub mod get_punishment_items;
pub mod get_regulation_docs;

pub fn make_router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(
            get_punishments::get_punishments,
        ))
        .routes(routes!(
            get_punishment_items::get_punishment_items,
        ))
        // .layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
        .routes(routes!(
            get_regulation_docs::get_regulation_docs,
        ))
        // .layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
        //   .layer(auth_jwt::prelude::AuthLayer::new(Role::Customer | Role::Inspector ))
        .with_state(state)
}
