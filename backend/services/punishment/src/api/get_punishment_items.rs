use std::{collections::HashMap, default, os::raw};

use anyhow::Ok;
use axum::{extract::State, http::StatusCode, response::{IntoResponse, Response}, Json};
use chrono::{NaiveDate, NaiveDateTime};
use serde::{Deserialize, Serialize};
use shared::prelude::{AppErr, IntoAppErr};
use tracing::info;
use tracing_subscriber::field::debug;
use utoipa_axum::{router::OpenApiRouter, routes};
use schema::prelude::*;
use uuid::Uuid;
use crate::AppState;

#[utoipa::path(
    post,
    path = "/get_punishment_items",
    tag = crate::MAIN_TAG,
    summary = "Get all items in punishment",
    responses(
        (status = 200, description = "Report added!", body=Vec<PunishmentItemResponse>),
    )
)]

pub async fn get_punishment_items(
    State(app): State<AppState>,
    Json(r): Json<PunishmentItemsRequest>,
) -> Result<Response, AppErr> {
    info!("{:?}", r);
    let rawResult = app.orm.punishment_item().select("where punishment = $1").bind(&r.punishment).fetch().await.into_app_err()?;
    let rawDocs = app.orm.regulation_docs().select("").fetch().await.into_app_err()?;
    let rawStatuses = app.orm.punishment_statuses().select("").fetch().await.into_app_err()?;

    let statuses: HashMap<i32, String> = rawStatuses.into_iter().map(|s| (s.id, s.title)).collect();
    let docs: HashMap<Uuid, Option<String>> = rawDocs.into_iter().map(|d| (d.uuid, d.title)).collect();

    let result = rawResult.iter().map(|r| {PunishmentItemResponse{
        punishment: r.punishment,
        uuid: r.uuid,
        correction_date_fact: r.correction_date_fact,
        correction_date_info: r.correction_date_info,
        is_suspend: r.is_suspend,
        comment: r.comment,
        punish_datetime: r.punish_datetime,
        regulation_doc: docs[&Uuid::new_v4()],
        correction_date_plan: r.correction_date_plan,
        title: r.title,
        punishment_item_status: statuses[&r.punishment_item_status],
        place: r.place,
    }}).collect();
    tracing::info!("Result: {:?}", result.len());
    Ok((StatusCode::OK, Json(result)).into_response()).into_app_err()
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]
pub struct PunishmentItemsRequest{
    #[schema(example=Uuid::new_v4)]
    punishment: uuid::Uuid,
}

#[derive(utoipa::ToSchema, Deserialize, Debug)]
pub struct PunishmentItemResponse{
    #[schema(example=Uuid::new_v4)]
    punishment: uuid::Uuid,
    #[schema(example=Uuid::new_v4)]
    uuid: uuid::Uuid,
    #[schema(example=NaiveDateTime::default)]
    correction_date_fact: Option<chrono::NaiveDate>,
    #[schema(example="")]
    correction_date_info: Option<String>,
    #[schema(example=false)]
    is_suspend: bool,
    #[schema(example="")]
    comment: Option<String>,
    #[schema(example=NaiveDateTime::default)]
    punish_datetime: chrono::NaiveDateTime,
    #[schema(example=Uuid::new_v4)]
    regulation_doc: Option<String>,
    #[schema(example=NaiveDateTime::default)]
    correction_date_plan: chrono::NaiveDate,
    #[schema(example="contravention title")]
    title: String,
    #[schema(example="status")]
    punishment_item_status: String,
    #[schema(example="1.23 4.56, ...")]
    place: String,
}