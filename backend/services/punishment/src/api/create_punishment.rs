use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use chrono::{NaiveDateTime};
use serde::{Deserialize};
use shared::prelude::{AppErr};
use orm::prelude::*;
use tracing::info;
use schema::prelude::*;
use uuid::Uuid;
use crate::{AppState, api::{ErrorExample, UuidResponse}};

#[utoipa::path(
    post,
    path = "/create_punishment",
    tag = crate::MANAGER_TAG,
    summary = "Create punishment with status & date",
    responses(
        (status = 200, description = "Punishment created", body=UuidResponse),
        (status = 409, description = "Punishment already exist", body=ErrorExample),
        (status = 400, description = "Project not found", body=ErrorExample),
    )
)]
pub async fn create_punishment(
    State(app): State<AppState>,
    Json(r): Json<PunishmentCreateRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    app.orm.project().select_by_pk(&r.project).await?
    .ok_or_else(|| AppErr::default().with_status(StatusCode::BAD_REQUEST).with_err_response("Project not found"))?;
        let mut statuses: Vec<i32> = vec![];
        let mut dates: Vec<NaiveDateTime> = vec![];
        
        for i in &r.items {
            statuses.push(i.punishment_item_status);
            dates.push(i.punish_datetime);
        }

        let punishment_datetime = *dates.iter().min()
                .ok_or_else(|| AppErr::default()
                .with_status(StatusCode::BAD_REQUEST)
                .with_err_response("Incorrect dates"))?;

        let status = *statuses.iter().max()
                .ok_or_else(|| AppErr::default()
                .with_status(StatusCode::BAD_REQUEST)
                .with_err_response("Incorrect statuses"))?;
        
        let uuid = Uuid::new_v4();
        let record = ActivePunishment{
            project: Set(r.project),
            custom_number: Set(r.custom_number),
            punish_datetime: Set(punishment_datetime),
            uuid: Set(uuid),
            punishment_status: Set(status)
        };
        let raw_punishment = app.orm.punishment().save(record, Insert).await?
        .ok_or_else(||AppErr::default().with_status(StatusCode::CONFLICT).with_err_response("Punishment already exist"))?;
        tracing::info!("Result: {:?}", raw_punishment);
        Ok((StatusCode::OK, Json(UuidResponse{uuid:uuid})).into_response())
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct PunishmentCreateRequest{
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    pub(crate) project: uuid::Uuid,
    #[schema(example="abc123")]
    pub(crate) custom_number: Option<String>,
    pub(crate) items: Vec<InsPunishmentItemsCreateRequest>
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct InsPunishmentItemsCreateRequest{
    #[schema(example=NaiveDateTime::default)]
    pub(crate) punish_datetime: chrono::NaiveDateTime,
    #[schema(example=52)]
    pub(crate) punishment_item_status: i32,
}