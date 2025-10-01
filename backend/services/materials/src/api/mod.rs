use std::collections::HashMap;

use axum::http::StatusCode;
use axum::response::IntoResponse;
use axum::{Json, response::Response};
use axum::extract::{Path, Query, State};
use orm::prelude::*;
use schema::prelude::{ActiveMaterials, Attachments, Materials, OrmMaterials};
use serde::{Deserialize, Serialize};
use shared::prelude::*;
use utoipa::{ToSchema};
use utoipa_axum::{router::OpenApiRouter, routes};

use crate::AppState;


pub fn router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(request_research))
        .routes(routes!(
            insert, 
            update,
            delete,
            get,
        ))
        .routes(routes!(
            get_by_project,
        ))
        .with_state(state)
        // .layer(auth_jwt::prelude::AuthLayer::new(Role::Foreman))
        .layer(axum::middleware::from_fn(auth_jwt::prelude::optional_token_extractor))
}

#[derive(Deserialize, ToSchema)]
pub struct MaterialInsertRequest {
    #[schema(example = 1.0)]
    volume: f64,
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    project: uuid::Uuid,
    #[schema(example = "2023-01-01")]
    delivery_date: chrono::NaiveDate,
    #[schema(example = 1)]
    measurement: i32,
    #[schema(example = "Material 1")]
    title: String
}

impl MaterialInsertRequest {
    pub fn into_active(self) -> ActiveMaterials {
        ActiveMaterials {
            volume: Set(self.volume),
            project: Set(self.project),
            delivery_date: Set(self.delivery_date),
            measurement: Set(self.measurement),
            title: Set(self.title),
            ..Default::default()
        }
    }
}

#[utoipa::path(
    post,
    path = "/material",
    tag = crate::MAIN_TAG,
    summary = "Insert a material",
    responses(
        (status = 200, description = "Success", body = Materials),
        (status = 409, description = "Material already exists (unreachable?)"),
    )
)]
pub async fn insert(
    State(app) : State<AppState>,
    Json(r) : Json<MaterialInsertRequest>
) -> Result<Response, AppErr> {
    let Some(r) = app.orm.materials().save(r.into_active(), Insert).await.into_app_err()? else {
        return Ok((StatusCode::CONFLICT).into_response());
    };
    Ok((StatusCode::OK, Json(r)).into_response())    
}


#[derive(Deserialize, ToSchema)]
pub struct MaterialUpdateRequest {
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    uuid: uuid::Uuid,
    #[schema(example=1.0)]
    #[serde(skip_serializing_if = "Option::is_none")]
    volume: Option<f64>,
    #[schema(example="2023-01-01")]
    #[serde(skip_serializing_if = "Option::is_none")]
    delivery_date: Option<chrono::NaiveDate>,
    #[schema(example=1)]
    #[serde(skip_serializing_if = "Option::is_none")]
    measurement: Option<i32>,
}

impl MaterialUpdateRequest {
    pub fn into_active(self) -> ActiveMaterials {
        ActiveMaterials {
            uuid: Set(self.uuid),
            volume: self.volume.map(|v|Set(v)).unwrap_or_default(),
            delivery_date: self.delivery_date.map(|v|Set(v)).unwrap_or_default(),
            measurement: self.measurement.map(|v|Set(v)).unwrap_or_default(),
            ..Default::default()
        }
    }
}

#[utoipa::path(
    put,
    path = "/material",
    tag = crate::MAIN_TAG,
    summary = "Update a material",
    responses(
        (status = 200, description = "Success", body = Uuid),
        (status = 404, description = "Material with id not found"),
    )
)]
pub async fn update(
    State(app) : State<AppState>,
    Json(r) : Json<MaterialUpdateRequest>
) -> Result<Response, AppErr> {
    let Some(r) = app.orm.materials().save(r.into_active(), Update).await.into_app_err()? else {
        return Ok((StatusCode::NOT_FOUND).into_response());
    };
    Ok((StatusCode::OK, Json(r.uuid)).into_response())  
}

#[utoipa::path(
    delete,
    path = "/material",
    tag = crate::MAIN_TAG,
    summary = "Update a material",
    responses(
        (status = 200, description = "Success", body = Uuid),
        (status = 404, description = "Material with id not found"),
    )
)]
pub async fn delete(
    State(app) : State<AppState>,
    Json(r) : Json<uuid::Uuid>
) -> Result<Response, AppErr> {
    let Some(r) = app.orm.materials().delete_by_pk(&r).await.into_app_err()? else {
        return Ok((StatusCode::NOT_FOUND).into_response());
    };
    Ok((StatusCode::OK, Json(r.uuid)).into_response())  
}


#[utoipa::path(
    get,
    path = "/material/{id}",
    tag = crate::MAIN_TAG,
    summary = "Get a material",
    responses(
        (status = 200, description = "Success", body = Materials),
        (status = 404, description = "Material with id not found"),
    )
)]
pub async fn get(
    State(app) : State<AppState>,
    Query(r) : Query<uuid::Uuid>
) -> Result<Response, AppErr> {
    let Some(r) = app.orm.materials().select_by_pk(&r).await.into_app_err()? else {
        return Ok((StatusCode::NOT_FOUND).into_response());
    };
    Ok((StatusCode::OK, Json(r)).into_response())  
}

// #[utoipa::path(
//     get,
//     path = "/materials/by_project_schedule_item/{id}",
//     tag = crate::MAIN_TAG,
//     summary = "Get all materials by subwork",
//     params(
//         ("project_schedule_item" = uuid::Uuid, Path, description = "ID of the project schedule item")
//     ),
//     responses(
//         (status = 200, description = "Success", body = Vec<MaterialsResponse>),
//     )
// )]
// pub async fn get_by_project_schedule_item(
//     State(app) : State<AppState>,
//     Path(project_schedule_item): Path<uuid::Uuid>
// ) -> Result<Response, AppErr> {
//     let r = app.orm.materials().select("where project_schedule_item = $1").bind(&project_schedule_item).fetch().await.into_app_err()?;
//     Ok((StatusCode::OK, Json(r)).into_response())
// }



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

#[derive(sqlx::FromRow, Debug)]
struct MaterialWithAttachment {
    #[sqlx(flatten)]
    material: Materials,
    #[sqlx(flatten)]
    attachment: OptionalAttachments,
}

#[derive(Serialize, ToSchema)]
struct MaterialWithAttachments {
    material: Materials,
    attachments: Vec<Attachments>,
}

#[utoipa::path(
    get,
    path = "/materials/by_project/{id}",
    tag = crate::MAIN_TAG,
    summary = "Get all materials by subwork",
    params(
        ("project" = uuid::Uuid, Path, description = "ID of the project")
    ),
    responses(
        (status = 200, description = "Success", body = Vec<MaterialWithAttachments>),
    )
)]
pub async fn get_by_project(
    State(app) : State<AppState>,
    Path(project): Path<uuid::Uuid>
) -> Result<Response, AppErr> {

    let rows = sqlx::query_as::<_, MaterialWithAttachment>("
        SELECT m.*, 
        a.uuid AS attachment_uuid,
        a.original_filename,
        a.base_entity_uuid,
        a.content_type
        FROM norm.materials m
        LEFT JOIN attachment.attachments a ON a.base_entity_uuid = m.uuid
        WHERE m.project = $1
    ").bind(&project).fetch_all(app.orm.get_executor()).await.into_app_err()?;

    let mut hm = HashMap::new();

    for row in rows {
        let a = row.attachment.into_attachments();
        let e = &mut hm.entry(row.material.uuid.clone())
            .or_insert_with(|| MaterialWithAttachments{
                attachments: vec![], 
                material: row.material
            })
            .attachments;
        let Some(a) = a else {continue};
        e.push(a);  
    }
    let v: Vec<MaterialWithAttachments> = hm.into_values().collect::<Vec<_>>();
    Ok((StatusCode::OK, Json(v)).into_response())
}


#[utoipa::path(
    put,
    path = "/materials/request_research/{id}",
    tag = crate::MAIN_TAG,
    summary = "Request mat research",
    params(
        ("material_id" = uuid::Uuid, Path, description = "ID of the project schedule item")
    ),
    responses(
        (status = 200, description = "Success"),
        (status = 404, description = "Material with id not found"),
    )
)]
pub async fn request_research(
    State(app) : State<AppState>,
    Path(material_id): Path<uuid::Uuid>
) -> Result<Response, AppErr> {
    let m = ActiveMaterials {
        uuid: Set(material_id),
        on_research: Set(true),
        ..Default::default()
    };
    let r = app.orm.materials()
        .save(m, Update).await.into_app_err()?;
    Ok((if r.is_some() {StatusCode::OK} else {StatusCode::NOT_FOUND}).into_response())
}