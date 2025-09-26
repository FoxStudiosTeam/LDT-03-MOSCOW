// use auth_jwt::prelude::Role;
use utoipa_axum::{router::OpenApiRouter, routes};
use crate::{AppState};

pub mod get_punishments;
pub mod get_punishment_items;
pub mod get_regulation_docs;
pub mod get_statuses;
pub mod create_punishment;
pub mod update_punishment;

pub fn make_router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(
            get_punishments::get_punishments,
            update_punishment::update_punishment,
            get_statuses::get_punishment_statuses,
        ))
        .routes(routes!(
            get_punishment_items::get_punishment_items,
        ))
        // .layer(axum::middleware::from_fn(auth_jwt::prelude::optional_token_extractor))
        .routes(routes!(
            get_regulation_docs::get_regulation_docs,
        ))
        .routes(routes!(
            create_punishment::create_punishment,
        ))
        // .layer(axum::middleware::from_fn(auth_jwt::prelude::optional_token_extractor))
        //   .layer(auth_jwt::prelude::AuthLayer::new(Role::Customer | Role::Inspector ))
        .with_state(state)
}
