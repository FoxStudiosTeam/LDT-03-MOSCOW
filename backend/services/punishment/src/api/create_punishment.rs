use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use chrono::{NaiveDate, NaiveDateTime};
use serde::{Deserialize};
use shared::prelude::{AppErr};
use orm::prelude::*;
use tracing::info;
use schema::prelude::*;
use uuid::Uuid;
use crate::{AppState};

#[utoipa::path(
    post,
    path = "/create_punishment",
    tag = crate::MAIN_TAG,
    summary = "Create punishment with punishment items",
    responses(
        (status = 200, description = "Punishment created"),
        (status = 400, description = "Punishment not created", body=str, example="Punishment not recorded to database"),
        (status = 404, description = "Project not found", body=str, example="Project not found"),
    )
)]

pub async fn create_punishment(
    State(app): State<AppState>,
    Json(r): Json<PunishmentCreateRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    let project = app.orm.project().select_by_pk(&r.project).await?;
    if let Some(_) = project {

        let mut statuses: Vec<i32> = vec![];
        let mut dates: Vec<NaiveDateTime> = vec![];
        
        for i in &r.items {
            statuses.push(i.punishment_item_status);
            dates.push(i.punish_datetime);
        }

        let punishment_datetime = *dates.iter().min()
                .ok_or_else(|| AppErr::default()
                .with_status(StatusCode::BAD_REQUEST)
                .with_response("Incorrect dates".into_response()))?;

        let status = *statuses.iter().max()
                .ok_or_else(|| AppErr::default()
                .with_status(StatusCode::BAD_REQUEST)
                .with_response("Incorrect statuses".into_response()))?;
        
        let uuid = Uuid::new_v4();
        let record = ActivePunishment{
            project: Set(r.project),
            custom_number: Set(r.custom_number),
            punish_datetime: Set(punishment_datetime),
            uuid: Set(uuid),
            punishment_status: Set(status)
        };
        let raw_punishment = app.orm.punishment().save(record, Insert).await?;
        info!("{:?}", raw_punishment);
        tracing::info!("Result: {:?}", raw_punishment);

        let mut result = !(raw_punishment.ok_or_else(|| AppErr::default()
        .with_status(StatusCode::BAD_REQUEST)
        .with_response("Punishment not recorded".into_response()))?
        .project.to_string().is_empty());
        
        let punishment = app.orm.punishment().select_by_pk(&uuid).await?;
        if let Some(_) = punishment {
            for raw_record in r.items {
                let data = ActivePunishmentItem { 
                    punishment: Set(uuid),
                    is_suspend: Set(raw_record.is_suspended), 
                    comment: Set(raw_record.comment), 
                    punish_datetime: Set(raw_record.punish_datetime), 
                    regulation_doc: Set(Some(raw_record.regulation_doc)), 
                    correction_date_plan: Set(raw_record.correction_date_plan), 
                    title: Set(raw_record.title), 
                    punishment_item_status: Set(raw_record.punishment_item_status), 
                    place: Set(raw_record.place),
                    ..Default::default()
                };

                let raw_item = app.orm.punishment_item().save(data, Insert).await?;
                tracing::info!("Result: {:?}", raw_item);
                result = !(raw_item.ok_or_else(|| AppErr::default()
                .with_status(StatusCode::BAD_REQUEST)
                .with_response("Result not recorded".into_response()))?
                .title.to_string().is_empty());
            };
        }
        Ok((StatusCode::OK, Json(result)).into_response())
    }
    else {
        Err(AppErr::default().with_status(StatusCode::NOT_FOUND).with_response("Project not found".into_response()))
    }
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct PunishmentCreateRequest{
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    pub(crate) project: uuid::Uuid,
    #[schema(example="abc123")]
    pub(crate) custom_number: Option<String>,
    pub(crate) items: Vec<PunishmentItemsCreateRequest>
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]

pub struct PunishmentItemsCreateRequest{
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