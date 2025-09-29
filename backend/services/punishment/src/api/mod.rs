use serde::{Deserialize, Serialize};
use auth_jwt::prelude::Role;
use utoipa_axum::{router::OpenApiRouter, routes};
use crate::{AppState};

pub mod get_regulation_docs;
pub mod get_statuses;
pub mod get_punishments;
pub mod create_punishment;
pub mod update_punishment;
pub mod delete_punishment;
pub mod get_punishment_items;
pub mod create_punishment_item;
pub mod update_punishment_item;

pub fn everyone(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(
            get_punishments::get_punishments,
            update_punishment::update_punishment,
            delete_punishment::delete_punishment
        ))
        .routes(routes!(
            get_punishment_items::get_punishment_items,
            update_punishment_item::update_punishment_item
        ))
        .routes(routes!(get_statuses::get_punishment_statuses))
        .routes(routes!(get_regulation_docs::get_regulation_docs))
        .layer(auth_jwt::prelude::AuthLayer::new(Role::Foreman | Role::AdministratorOnly | Role::Customer | Role::Inspector))
        .layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
        .with_state(state)
}

pub fn inspector_customer(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(create_punishment::create_punishment))
        .routes(routes!(create_punishment_item::create_punishment_item))
        .layer(auth_jwt::prelude::AuthLayer::new(Role::Customer | Role::Inspector | Role::AdministratorOnly ))
        .layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
        .with_state(state)
}

#[derive(utoipa::ToSchema, Deserialize)]
pub(crate) struct ErrorExample {
    #[schema(example="error message")]
    pub(crate) message: String,
}

#[derive(utoipa::ToSchema, Debug, Serialize)]
pub(crate) struct UuidResponse {
    #[schema(example=uuid::Uuid::new_v4)]
    pub(crate) uuid: uuid::Uuid,
}