use auth_jwt::prelude::Role;
use axum::http::StatusCode;
use axum::response::IntoResponse;
use axum::{Json, response::Response};
use axum::extract::{Query, State};
use orm::prelude::*;
use schema::prelude::{ActiveMaterials, Attachments, Materials, OrmMaterials};
use serde::{Deserialize};
use shared::prelude::*;
use utoipa::{ToSchema};
use utoipa_axum::{router::OpenApiRouter, routes};

use crate::AppState;


pub fn router(state: AppState) -> OpenApiRouter {
    OpenApiRouter::new()
        .routes(routes!(
            insert, 
            update,
            delete,
            get,
        ))
        .routes(routes!(
            get_by_project_schedule_item,
        ))
        .with_state(state)
        // .layer(auth_jwt::prelude::AuthLayer::new(Role::Operator))
        .layer(axum::middleware::from_fn(auth_jwt::prelude::optional_token_extractor))
}

#[derive(Deserialize, ToSchema)]
pub struct MaterialInsertRequest {
    #[schema(example = 1.0)]
    volume: f64,
    #[schema(example="a1b15396-7f4a-40e0-8afd-2785a0460d33")]
    project_schedule_item: uuid::Uuid,
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
            project_schedule_item: Set(self.project_schedule_item),
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
        (status = 200, description = "Success", body = Uuid),
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
    Ok((StatusCode::OK, Json(r.uuid)).into_response())    
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


#[derive(Clone, Debug, ToSchema)]
pub struct MaterialsResponse {
    pub volume: f64,
    pub uuid: uuid::Uuid,
    pub project_schedule_item: uuid::Uuid,
    pub delivery_date: chrono::NaiveDate,
    pub measurement: i32,
    pub title: String,
    pub attachments: Vec<Attachments>,
}

#[utoipa::path(
    get,
    path = "/material/{id}",
    tag = crate::MAIN_TAG,
    summary = "Update a material",
    responses(
        (status = 200, description = "Success", body = MaterialsResponse),
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

#[utoipa::path(
    get,
    path = "/materials/by_project_schedule_item/{id}",
    tag = crate::MAIN_TAG,
    summary = "Update a material",
    responses(
        (status = 200, description = "Success", body = Vec<MaterialsResponse>),
    )
)]
pub async fn get_by_project_schedule_item(
    State(app) : State<AppState>,
    Query(s) : Query<uuid::Uuid>
) -> Result<Response, AppErr> {
    let r = app.orm.materials().select("where project_schedule_item = $1").bind(&s).fetch().await.into_app_err()?;
    Ok((StatusCode::OK, Json(r)).into_response())
}