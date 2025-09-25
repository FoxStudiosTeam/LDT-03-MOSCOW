use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use serde::{Deserialize};
use shared::{prelude::{AppErr, IntoAppErr}};
use tracing::info;
use schema::prelude::*;
use uuid::Uuid;
use crate::{AppState};

#[utoipa::path(
    post,
    path = "/get_punishment_items",
    tag = crate::MAIN_TAG,
    summary = "Get all items in punishment",
    responses(
        (status = 200, description = "Punishment items fetched", body=Vec<PunishmentItem>),
    )
)]

pub async fn get_punishment_items(
    State(app): State<AppState>,
    Json(r): Json<PunishmentItemsRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    app.orm.punishment().select_by_pk(&r.punishment).await?
    .ok_or_else(|| AppErr::default()
    .with_status(StatusCode::NOT_FOUND)
    .with_err_response("Punishment not found"))?;
    let result = app.orm.punishment_item().select("where punishment = $1").bind(&r.punishment).fetch().await.into_app_err()?;
    tracing::info!("Result: {:?}", result.len());

    Ok((StatusCode::OK, Json(result)).into_response())

}

#[derive(utoipa::ToSchema, Deserialize, Debug)]
pub struct PunishmentItemsRequest{
    #[schema(example=Uuid::new_v4)]
    punishment: uuid::Uuid,
}