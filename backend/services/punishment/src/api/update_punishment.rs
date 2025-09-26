use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use serde::{Deserialize};
use shared::prelude::{AppErr};
use orm::prelude::*;
use tracing::info;
use schema::prelude::*;
use uuid::Uuid;
use crate::{AppState, api::{ErrorExample,UuidResponse}};

#[utoipa::path(
    put,
    path = "/update_punishment",
    tag = crate::MAIN_TAG,
    summary = "Update punishment with status",
    responses(
        (status = 200, description = "Punishment updated", body=UuidResponse),
        (status = 500, description = "Punishment not updated", body=ErrorExample),
        (status = 404, description = "Punishment not found", body=ErrorExample),
    )
)]

pub async fn update_punishment(
    State(app): State<AppState>,
    Json(r): Json<PunishmentUpdRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);

    let ext_p = app.orm.punishment().select_by_pk(&r.uuid).await?.ok_or_else(|| AppErr::default()
    .with_status(StatusCode::NOT_FOUND)
    .with_err_response("Punishment not found"))?;

    if let Some(p) = r.project {
        app.orm.project().select_by_pk(&p).await?.ok_or_else(|| AppErr::default()
        .with_status(StatusCode::NOT_FOUND)
        .with_err_response("Punishment not found"))?;
    } 

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
    let punishment = app.orm.punishment().save(record, Update).await?.ok_or_else(|| AppErr::default()
    .with_status(StatusCode::INTERNAL_SERVER_ERROR)
    .with_err_response("Punishment not recorded"))?;
    info!("{:?}", punishment);
    tracing::info!("Result: {:?}", punishment);
    Ok((StatusCode::OK, Json(UuidResponse{uuid: uuid})).into_response())
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
    #[schema(example=52)]
    pub(crate) punishment_item_status: Option<i32>,
}