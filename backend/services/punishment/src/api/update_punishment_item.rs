use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use chrono::{NaiveDate};
use serde::{Deserialize};
use shared::prelude::{AppErr};
use orm::prelude::*;
use tracing::info;
use schema::prelude::*;
use uuid::Uuid;
use crate::{AppState, api::{ErrorExample, UuidResponse}};

#[utoipa::path(
    put,
    path = "/update_punishment_item",
    tag = crate::MAIN_TAG,
    summary = "Update punishment item",
    responses(
        (status = 200, description = "Punishment item updated", body=UuidResponse),
        (status = 500, description = "Punishment item not updated", body=ErrorExample),
        (status = 404, description = "Punishment not found", body=ErrorExample),
    )
)]

pub async fn update_punishment_item(
    State(app): State<AppState>,
    Json(r): Json<PunishmentItemUpdRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);

    app.orm.punishment().select_by_pk(&r.uuid).await?.ok_or_else(|| AppErr::default()
    .with_status(StatusCode::NOT_FOUND)
    .with_err_response("Punishment not found"))?;
    let uuid = r.uuid;
        app.orm.punishment_item().select_by_pk(&uuid).await?
        .ok_or_else(|| AppErr::default()
        .with_status(StatusCode::NOT_FOUND)
        .with_err_response("Punishment item not found"))?;
        app.orm.punishment_item().save(r.into_active(), Update).await?
        .ok_or_else(|| AppErr::default()
        .with_status(StatusCode::INTERNAL_SERVER_ERROR)
        .with_err_response("Punishment item not recorded"))?;
    Ok((StatusCode::OK, Json(UuidResponse{uuid:uuid})).into_response())
}
#[derive(utoipa::ToSchema, Deserialize, Debug, Default)]

pub struct PunishmentItemUpdRequest{
    #[schema(example=Uuid::new_v4)]
    pub(crate) uuid: Uuid,
    #[schema(example="title of contravention")]
    pub(crate) title: Option<String>,
    #[schema(example=NaiveDate::default)]
    pub(crate) correction_date_fact: Option<chrono::NaiveDate>,
    #[schema(example=52)]
    pub(crate) punishment_item_status: Option<i32>,
    #[schema(example="aboba loh")]
    pub(crate) comment: Option<String>,
    #[schema(example="aboba loh")]
    pub(crate) correction_date_info: Option<String>,
    #[schema(example=Uuid::new_v4)]
    pub(crate) regulation_doc: Option<Uuid>,
    #[schema(example=true)]
    pub(crate) is_suspended: Option<bool>,
}

impl PunishmentItemUpdRequest {
    pub fn into_active(self) -> ActivePunishmentItem {
        ActivePunishmentItem {
            uuid: Set(self.uuid),
            comment: self.comment.map(|v| Set(Some(v))).unwrap_or_default(),
            correction_date_fact: self.correction_date_fact.map(|v| Set(Some(v))).unwrap_or_default(),
            correction_date_info: self.correction_date_info.map(|v| Set(Some(v))).unwrap_or_default(),
            is_suspend: self.is_suspended.map(|v| Set(v)).unwrap_or_default(),
            punishment_item_status: self.punishment_item_status.map(|v| Set(v)).unwrap_or_default(),
            regulation_doc: self.regulation_doc.map(|v| Set(Some(v))).unwrap_or_default(),
            title: self.title.map(|v| Set(v)).unwrap_or_default(),
            ..Default::default()
        }
    }
}