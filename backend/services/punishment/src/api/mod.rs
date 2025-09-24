// use auth_jwt::prelude::Role;
use utoipa_axum::{router::OpenApiRouter, routes};
use crate::{AppState};

pub mod get_punishments;
pub mod get_punishment_items;
pub mod get_regulation_docs;
pub mod get_regulation_doc;
pub mod get_statuses;

pub fn make_router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(
            get_punishments::get_punishments,
            get_statuses::get_punishment_statuses,
        ))
        .routes(routes!(
            get_punishment_items::get_punishment_items,
        ))
        // .layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
        .routes(routes!(
            get_regulation_docs::get_regulation_docs,
        ))
        .routes(routes!(
            get_regulation_doc::get_regulation_doc,
        ))
        // .layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
        //   .layer(auth_jwt::prelude::AuthLayer::new(Role::Customer | Role::Inspector ))
        .with_state(state)
}
