use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use chrono::{NaiveDate};
use serde::{Deserialize};
use shared::prelude::{AppErr};
use orm::prelude::*;
use tracing::info;
use schema::prelude::*;
use uuid::Uuid;
use crate::{AppState};

#[utoipa::path(
    put,
    path = "/update_punishment",
    tag = crate::MAIN_TAG,
    summary = "Update punishment with punishment items",
    responses(
        (status = 200, description = "Punishment updated"),
        (status = 500, description = "Punishment not updated", body=str, example="Punishment not recorded"),
        (status = 404, description = "Punishment not found", body=str, example="Punishment not found"),
    )
)]

pub async fn update_punishment(
    State(app): State<AppState>,
    Json(r): Json<PunishmentUpdRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);

    let ext_p = app.orm.punishment().select_by_pk(&r.uuid).await?.ok_or_else(|| AppErr::default()
    .with_status(StatusCode::NOT_FOUND)
    .with_response("Punishment not found".into_response()))?;

    match r.project {
        Some(p) => app.orm.project().select_by_pk(&p).await?,
        None => app.orm.project().select_by_pk(&ext_p.project).await?,
    }.ok_or_else(|| AppErr::default()
        .with_status(StatusCode::NOT_FOUND)
        .with_response("Punishment not found".into_response()))?;         

    let status = match &r.items {
        Some(items) => {
            let mut statuses = vec![];

            for i in items {
                match i.punishment_item_status {
                    Some(num) => statuses.push(num),
                    None => (),
                };
            };

            let s = *statuses.iter().max().unwrap_or(&ext_p.punishment_status);

            s
        },
        None => ext_p.punishment_status
    };
    
    let uuid = r.uuid;
    let record = ActivePunishment{
        project: r.project.map(|v| Set(v)).unwrap_or_default(),
        custom_number: r.custom_number.map(|v| Set(Some(v))).unwrap_or_default(),
        uuid: Set(uuid),
        punishment_status: Set(status),
        ..Default::default()
    };
    let raw_punishment = app.orm.punishment().save(record, Update).await?.ok_or_else(|| AppErr::default()
    .with_status(StatusCode::INTERNAL_SERVER_ERROR)
    .with_response("Punishment not recorded".into_response()))?;
    info!("{:?}", raw_punishment);
    tracing::info!("Result: {:?}", raw_punishment);
    
    let result: () = match r.items {
        Some(items) => {
            for item in items {
                app.orm.punishment_item().select_by_pk(&item.uuid).await?
                .ok_or_else(|| AppErr::default()
                .with_status(StatusCode::NOT_FOUND)
                .with_response("Punishment item not found".into_response()))?;
                app.orm.punishment_item().save(item.into_active(), Update).await?
                .ok_or_else(|| AppErr::default()
                .with_status(StatusCode::INTERNAL_SERVER_ERROR)
                .with_response("Punishment item not recorded".into_response()))?;
                ()
            }
        },
        None => (),
    };
    Ok((StatusCode::OK, Json(result)).into_response())
}


#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct PunishmentUpdRequest{
    #[schema(example=Uuid::new_v4)]
    pub(crate) uuid: Uuid,
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    pub(crate) project: Option<uuid::Uuid>,
    #[schema(example="abc123")]
    pub(crate) custom_number: Option<String>,
    // #[schema(example=PunishmentItemsRequest)]
    pub(crate) items: Option<Vec<PunishmentItemsUpdRequest>>
}

#[derive(utoipa::ToSchema, Deserialize, Debug, Default)]

pub struct PunishmentItemsUpdRequest{
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

impl PunishmentItemsUpdRequest {
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