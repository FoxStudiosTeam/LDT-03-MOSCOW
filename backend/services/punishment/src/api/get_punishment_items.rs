use std::{collections::HashMap};
use axum::{Json, extract::{Query, State}, http::StatusCode, response::{IntoResponse, Response}};
use serde::{Deserialize, Serialize};
use shared::{prelude::{AppErr, IntoAppErr}};
use tracing::{info, warn};
use schema::prelude::*;
use utoipa::{IntoParams, ToSchema};
use uuid::Uuid;
use crate::{AppState};


#[derive(ToSchema, Serialize)]
pub struct PunishmentItemWithAttachments {
    pub punishment_item: PunishmentItem,
    pub attachments: Vec<Attachments>,
}

#[derive(sqlx::FromRow, Debug)]
struct ItemWithAttachment {
    #[sqlx(flatten)]
    punishment_item: PunishmentItem,
    #[sqlx(flatten)]
    attachment: OptionalAttachments,
}

#[derive(sqlx::FromRow, Default, Debug)]
pub struct OptionalAttachments {
    pub original_filename: Option<String>,
    pub attachment_uuid: Option<uuid::Uuid>,
    pub base_entity_uuid: Option<uuid::Uuid>,
    pub content_type: Option<String>,
}

impl OptionalAttachments {
    fn into_attachments(self) -> Option<Attachments> {
        Some(Attachments {
            original_filename: self.original_filename?,
            uuid: self.attachment_uuid?,
            base_entity_uuid: self.base_entity_uuid?,
            content_type: self.content_type,
        })
    }
}


#[utoipa::path(
    get,
    path = "/get_punishment_items",
    tag = crate::ANY_TAG,
    params(PunishmentItemsRequest),
    summary = "Get all items in punishment",
    responses(
        (status = 200, description = "Punishment items fetched", body=Vec<PunishmentItemWithAttachments>),
    )
)]
pub async fn get_punishment_items(
    State(app): State<AppState>,
    Query(r): Query<PunishmentItemsRequest>,
) -> Result<Response, AppErr> {
    let rows = sqlx::query_as::<_, ItemWithAttachment>("
        SELECT pi.*, 
        a.uuid AS attachment_uuid,
        a.original_filename,
        a.base_entity_uuid,
        a.content_type
        FROM journal.punishment_item pi
        LEFT JOIN attachment.attachments a ON a.base_entity_uuid = pi.uuid
        WHERE pi.punishment = $1
    ").bind(r.punishment_id).fetch_all(app.orm.get_executor()).await.into_app_err()?;

    info!("{:#?}", rows);

    let mut hm = HashMap::new();

    for row in rows {
        let a = row.attachment.into_attachments();
        let e = &mut hm.entry(row.punishment_item.uuid.clone())
            .or_insert_with(|| PunishmentItemWithAttachments{
                attachments: vec![], 
                punishment_item: row.punishment_item
            })
            .attachments;
        let Some(a) = a else {continue};
        e.push(a);  
    }
    let v = hm.into_values().collect::<Vec<_>>();
    Ok((StatusCode::OK, Json(v)).into_response())
}

#[derive(utoipa::ToSchema, Deserialize, Debug, IntoParams)]
pub struct PunishmentItemsRequest{
    #[schema(example=Uuid::new_v4)]
    #[param(example=Uuid::new_v4)]
    punishment_id: uuid::Uuid,
}


#[derive(utoipa::ToSchema, Deserialize, Debug, IntoParams)]
pub struct PunishmentItemsByProjectRequest{
    #[schema(example=Uuid::new_v4)]
    #[param(example=Uuid::new_v4)]
    project_uuid: uuid::Uuid,
}


#[utoipa::path(
    get,
    path = "/get_punishment_items_by_project",
    tag = crate::ANY_TAG,
    params(PunishmentItemsByProjectRequest),
    summary = "Get all items in punishment",
    responses(
        (status = 200, description = "Punishment items fetched", body=PunishmentsByProjectResponse),
    )
)]
pub async fn get_punishment_items_by_project(
    State(app): State<AppState>,
    Query(r): Query<PunishmentItemsByProjectRequest>,
) -> Result<Response, AppErr> {
    let rows = sqlx::query_as::<_, PunishmentItemWithAttachment>("
        SELECT 
            p.uuid AS punishment_uuid,
            p.custom_number AS punishment_custom_number,
            p.punish_datetime as punishment_datetime,
            p.punishment_status,
            pi.uuid AS item_uuid,
            pi.punishment AS item_punishment,
            pi.*,
            a.uuid AS attachment_uuid,
            a.original_filename,
            a.base_entity_uuid,
            a.content_type
        FROM journal.punishment p
        LEFT JOIN journal.punishment_item pi 
            ON pi.punishment = p.uuid
        LEFT JOIN attachment.attachments a 
            ON a.base_entity_uuid = pi.uuid
        WHERE p.project = $1
    ").bind(r.project_uuid).fetch_all(app.orm.get_executor()).await.into_app_err()?;

    let mut punishment_items = HashMap::new();

    let mut hm = HashMap::new();

    

    for row in rows {
        hm.entry(row.punishment_uuid.clone()).or_insert_with(|| PunishmentResponse{
            uuid: row.punishment_uuid.clone(),
            custom_number: row.punishment_custom_number.clone(),
            punish_datetime: row.punishment_datetime.clone(),
            punishment_status: row.punishment_status.clone(),
            punishment_items: vec![],
        });

        let a = row.attachment.into_attachments();
        let e = &mut punishment_items.entry(row.punishment_item.uuid.clone())
            .or_insert_with(|| PunishmentItemWithAttachments{
                attachments: vec![], 
                punishment_item: row.punishment_item
            })
            .attachments;
        let Some(a) = a else {continue};
        e.push(a); 
    }
    for (_k, v) in punishment_items.into_iter() {
        let Some(resp) = hm.get_mut(&v.punishment_item.punishment) else {
            warn!("Could not find punishment: {}", v.punishment_item.punishment);
            continue
        };
        resp.punishment_items.push(v);
    }

    Ok((StatusCode::OK, Json(PunishmentsByProjectResponse{ punishments: hm.into_values().collect() })).into_response())
}


#[derive(ToSchema, Serialize)]
struct PunishmentResponse {
    uuid: uuid::Uuid,
    custom_number: String,
    punish_datetime: chrono::NaiveDateTime,
    punishment_status: i32,
    punishment_items: Vec<PunishmentItemWithAttachments>,
}

#[derive(ToSchema, Serialize)]
struct PunishmentsByProjectResponse {
    punishments: Vec<PunishmentResponse>,
}

#[derive(sqlx::FromRow)]
struct PunishmentItemWithAttachment {
    punishment_uuid: uuid::Uuid,
    punishment_custom_number: String,
    punishment_datetime: chrono::NaiveDateTime,
    punishment_status: i32,
    item_uuid: uuid::Uuid,
    item_punishment: uuid::Uuid,
    #[sqlx(flatten)]
    punishment_item: PunishmentItem,
    #[sqlx(flatten)]
    attachment: OptionalAttachments,
}