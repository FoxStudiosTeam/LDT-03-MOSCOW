use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use chrono::{NaiveDate, NaiveDateTime};
use serde::{Deserialize};
use shared::prelude::{AppErr};
use orm::prelude::*;
use tracing::info;
use schema::prelude::*;
use uuid::Uuid;
use crate::{AppState, api::{ErrorExample, UuidResponse}};

#[utoipa::path(
    post,
    path = "/create_punishment_item",
    tag = crate::MAIN_TAG,
    summary = "Create punishment items",
    responses(
        (status = 200, description = "Punishment item created", body=UuidResponse),
        (status = 400, description = "Punishment does not exist", body=ErrorExample),
        (status = 409, description = "Punishment item already exist", body=ErrorExample),
    )
)]
pub async fn create_punishment_item(
    State(app): State<AppState>,
    Json(r): Json<PunishmentItemCreateRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    app.orm.punishment().select_by_pk(&r.punishment).await?
    .ok_or_else(||AppErr::default().with_status(StatusCode::BAD_REQUEST).with_err_response("Punishment does not exist"))?;
    let uuid = Uuid::new_v4();
    let data = ActivePunishmentItem { 
        punishment: Set(r.punishment),
        is_suspend: Set(r.is_suspended), 
        comment: Set(r.comment), 
        punish_datetime: Set(r.punish_datetime), 
        regulation_doc: Set(Some(r.regulation_doc)), 
        correction_date_plan: Set(r.correction_date_plan), 
        title: Set(r.title), 
        punishment_item_status: Set(r.punishment_item_status), 
        place: Set(r.place),
        uuid: Set(uuid),
        ..Default::default()
    };

    let item = app.orm.punishment_item().save(data, Insert).await?
    .ok_or_else(||AppErr::default().with_status(StatusCode::CONFLICT).with_err_response("Punishment item already exist"))?;
    tracing::info!("Result: {:?}", item);
    Ok((StatusCode::OK, Json(UuidResponse{uuid:uuid})).into_response())
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct PunishmentItemCreateRequest{
    #[schema(example=Uuid::new_v4)]
    pub(crate) punishment: Uuid,
    #[schema(example="title of contravention")]
    pub(crate) title: String,
    #[schema(example=NaiveDateTime::default)]
    pub(crate) punish_datetime: chrono::NaiveDateTime,
    #[schema(example=NaiveDate::default)]
    pub(crate) correction_date_plan: chrono::NaiveDate,
    #[schema(example=52)]
    pub(crate) punishment_item_status: i32,
    #[schema(example="aboba loh")]
    pub(crate) comment: Option<String>,
    #[schema(example="12.34 56.78")]
    pub(crate) place: String,
    #[schema(example=Uuid::new_v4)]
    pub(crate) regulation_doc: Uuid,
    #[schema(example=true)]
    pub(crate) is_suspended: bool,
}