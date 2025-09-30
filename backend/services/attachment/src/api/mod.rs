use utoipa::IntoParams;
use utoipa::ToSchema;
use utoipa_axum::{router::OpenApiRouter, routes};
use crate::state::AppState;
use schema::prelude::*;
use axum::extract::Query;
use axum::extract::State;
use axum::extract::Multipart;
use shared::prelude::IntoAppErr;


pub fn router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(upload_project))
        .routes(routes!(upload_reports))
        .routes(routes!(upload_punishment_item))
        .routes(routes!(upload_materials))
        .with_state(state)
        // .layer(auth_jwt::prelude::AuthLayer::new(Role::Foreman | Role::Customer | Role::Inspector))
        .layer(axum::middleware::from_fn(auth_jwt::prelude::optional_token_extractor))
}


#[derive(IntoParams, ToSchema, serde::Deserialize)]
pub struct AttachmentParams {
    pub id: uuid::Uuid
}

use axum::extract::Json;
use shared::prelude::ErrorWrapper;
use axum::response::IntoResponse;

macro_rules! uploads {
    ($($name:ident)*) => {
        paste::paste! {
            $(
                #[utoipa::path(
                    post,
                    path = concat!("/attach/", stringify!($name)),
                    params(AttachmentParams),
                    tag = crate::MAIN_TAG,
                    request_body(description = "Multipart file", content_type = "multipart/form-data"),
                    summary = concat!("Attach files to ", stringify!($name), " ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️"),
                    responses(
                        (status = 200, description = "Success", body = Attachments),
                        (status = 401, description = "Unauthorized"),
                        (status = 404, description = "Not Found"),
                    )
                )]
                pub async fn [< upload_ $name >](
                    State(app) : State<crate::state::AppState>,
                    Query(params) : Query<AttachmentParams>,
                    multipart : Multipart,
                ) -> Result<axum::response::Response, shared::prelude::AppErr> {
                    if app.orm.[< $name >]().select_by_pk(&params.id).await.into_app_err()?.is_none() {
                        return Ok((http::status::StatusCode::NOT_FOUND, Json(ErrorWrapper{message: concat!("Id not found in ", stringify!($name)).to_string()})).into_response());
                        // tracing::warn!("NOT FOUND");
                    }
                    app.upload(params, multipart).await
                }
            )*
        }
    };
}

uploads!(project reports punishment_item materials);
