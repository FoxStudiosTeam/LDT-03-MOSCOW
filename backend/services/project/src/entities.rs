use schema::prelude::*;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use sqlx::prelude::{FromRow, Type};
use utoipa::{IntoParams, ToSchema};
use uuid::Uuid;

#[derive(ToSchema, Deserialize)]
pub struct CreateWorkCategoryRequest {
    pub title : String,
    pub kpgz : i32,
}

#[derive(ToSchema, Serialize)]
pub struct ProjectStatusesResponse {
    pub data: Vec<ProjectStatuses>
}


#[derive(ToSchema, Deserialize)]
pub struct UpdateWorkCategoryRequest {
    pub title : Option<String>,
    pub kpgz : Option<i32>,
    pub uuid : Uuid
}

#[derive(ToSchema, Deserialize)]
pub struct CreateUpdateWorkRequest {
    pub work_category_uuid : Uuid,
    pub title : String,
    pub uuid : Option<Uuid>
}

// #[derive(ToSchema, Serialize)]
// pub struct SaveWorkResponse {
//     pub items : Option<Works>
// }

// #[derive(ToSchema, Serialize)]
// pub struct GetWorksByCategoryResponse {
//     pub items: Vec<Works>
// }

#[derive(ToSchema, Deserialize)]
pub struct GetWorksByCategoryRequest {
    pub work_category_uuid : Uuid
}

#[derive(ToSchema, Serialize)]
pub struct GetKpgz {
    pub items : Vec<Kpgz>
}

#[derive(ToSchema, Serialize)]
pub struct GetWorkCategoriesResponse {
    pub items : Vec<WorkCategory>
}

#[derive(ToSchema, Deserialize)]
pub struct GetProjectRequest {
    pub address : Option<String>,
    pub pagination : Option<Pagination>
}
#[derive(ToSchema, Deserialize)]
pub struct CreateProjectRequest {
    pub address : Option<String>,
    pub polygon : Option<sqlx::types::JsonValue>,
}

#[derive(ToSchema, Deserialize)]
pub struct SetProjectForemanRequest {
    pub first_name : String,
    pub last_name : String,
    pub patronymic : String,
    pub uuid: Uuid
}

#[derive(ToSchema, Deserialize)]
pub struct Pagination {
    pub offset : i32,
    pub limit : i32
}

#[derive(ToSchema, Deserialize, IntoParams)]
pub struct ProjectRequest {
    pub project_uuid : Uuid
}
#[derive(ToSchema, Deserialize)]
pub struct AddIkoToProjectRequest {
    pub project_uuid : Uuid
}

#[derive(ToSchema, Deserialize)]
pub struct CreateProjectScheduleRequest {
    pub project_uuid : Uuid,
    pub work_uuid : Uuid,
}


#[derive(ToSchema, Deserialize)]
pub struct SetWorksInScheduleRequest {
    pub project_schedule_uuid : Uuid,
    pub items : Vec<SetWorkInScheduleRequest>
}


#[derive(ToSchema,Deserialize)]
pub struct SetWorkInScheduleRequest {
    pub start_date : chrono::NaiveDate,
    pub end_date : chrono::NaiveDate,
    pub uuid : Option<Uuid>,
    pub title : String,
    pub target_volume : f64,
    pub is_complete: bool,
    pub measurement : i32,
}


#[derive(ToSchema, Deserialize)]
pub struct GetProjectScheduleRequest {
    pub project_uuid : Uuid
}
#[derive(ToSchema, Serialize)]
pub struct GetProjectScheduleResponse {
    pub data : Vec<ProjectScheduleCategoryPartResponse>
}

#[derive(ToSchema, Serialize)]
pub struct ProjectScheduleCategoryPartResponse {
    pub uuid: Uuid,
    pub title: String,
    pub items: Vec<ProjectScheduleItemResponse>,
}

#[derive(ToSchema, Serialize)]
pub struct ProjectScheduleItemResponse {
    pub uuid: Uuid,
    pub title: String,
    pub start_date: chrono::NaiveDate,
    pub end_date: chrono::NaiveDate,
    pub is_deleted: bool,
    pub is_draft: bool,
    pub is_completed: bool,
    pub target_volume: f64,
    pub measurement: i32
}

impl ProjectScheduleItemResponse {
    pub fn from_items(items: ProjectScheduleItems) -> Self {
        Self {
            uuid: items.uuid,
            title: items.title,
            start_date: items.start_date,
            end_date: items.end_date,
            is_deleted: items.is_deleted,
            is_draft: items.is_draft,
            is_completed: items.is_completed,
            target_volume: items.target_volume,
            measurement: items.measurement
        }
    }
}

// ProjectStatus - таблица статусов проекта.
#[repr(i32)]
#[derive(Debug, Clone, Copy)]
pub enum ProjectStatus {
    New,
    PreActive, 
    Normal,
    SomeWarnings,
    LowPunishment,
    NormalPunishment,
    HighPunishment,
    Suspend
}

impl TryFrom<i32> for ProjectStatus {
    type Error = ();

    fn try_from(v: i32) -> Result<Self, Self::Error> {
        match v {
            x if x == ProjectStatus::New as i32 => Ok(ProjectStatus::New),
            x if x == ProjectStatus::PreActive as i32 => Ok(ProjectStatus::PreActive),
            x if x == ProjectStatus::Suspend as i32 => Ok(ProjectStatus::Suspend),
            x if x == ProjectStatus::Normal as i32 => Ok(ProjectStatus::Normal),
            x if x == ProjectStatus::LowPunishment as i32 => Ok(ProjectStatus::LowPunishment),
            x if x == ProjectStatus::NormalPunishment as i32 => Ok(ProjectStatus::NormalPunishment),
            x if x == ProjectStatus::HighPunishment as i32 => Ok(ProjectStatus::HighPunishment),
            x if x == ProjectStatus::SomeWarnings as i32 => Ok(ProjectStatus::SomeWarnings),
            _ => Err(()),
        }
    }
}

#[derive(ToSchema, Serialize)]
pub struct GetProjectResult {
    pub result : Vec<Project>,
    pub total: i64
}


#[derive(ToSchema, Debug, Serialize)]
pub struct ProjectWithAttachments {
    pub project: Project,
    pub attachments: Vec<Attachments>,
}

#[derive(ToSchema, Serialize)]
pub struct GetProjectWithAttachmentResult {
    pub result : Vec<NamedProjectWithAttachments>,
    pub total: i64
}

#[derive(ToSchema, Debug, Serialize)]
pub struct NamedProjectWithAttachments {
    pub project: NamedProject,
    pub attachments: Vec<Attachments>,
}


#[derive(sqlx::FromRow, Debug, ToSchema, Serialize)]
pub struct NamedProject {
    pub status: i32,
    pub polygon: serde_json::Value,
    pub start_date: Option<chrono::NaiveDate>,
    pub end_date: Option<chrono::NaiveDate>,
    pub uuid: uuid::Uuid,
    pub foreman: Option<String>,
    pub created_at: chrono::NaiveDateTime,
    pub address: String,
    pub created_by: Option<String>,
}

#[derive(sqlx::FromRow, Debug)]
pub struct RowProjectWithAttachment {
    #[sqlx(flatten)]
    pub project: NamedProject,
    #[sqlx(flatten)]
    pub attachment: OptionalAttachments,
}

#[derive(sqlx::FromRow, Default, Debug)]
pub struct OptionalAttachments {
    pub original_filename: Option<String>,
    pub attachment_uuid: Option<uuid::Uuid>,
    pub base_entity_uuid: Option<uuid::Uuid>,
    pub content_type: Option<String>,
}

impl OptionalAttachments {
    pub fn into_attachments(self) -> Option<Attachments> {
        Some(Attachments {
            original_filename: self.original_filename?,
            uuid: self.attachment_uuid?,
            base_entity_uuid: self.base_entity_uuid?,
            content_type: self.content_type,
        })
    }
}

#[derive(Default, Debug, ToSchema, Deserialize, IntoParams)]
pub struct DeleteProjectScheduleRequest{
    pub project_schedule_uuid : Uuid
}

#[derive(Deserialize, FromRow)]
pub struct TitledSchedule {
    pub uuid : Uuid,
    pub title : String,
}


#[derive(Deserialize, FromRow, ToSchema, IntoParams)]
pub struct GetProjectInspectorsRequest {
    pub project_uuid : Uuid
}


#[derive(Deserialize, Serialize, FromRow, ToSchema)]
pub struct InspectorInfo {
    pub uuid: Uuid,
    pub fcs: String
}

#[derive(Deserialize, Serialize, FromRow, ToSchema)]
pub struct GetProjectInspectorsResponse {
    pub inspectors : Vec<InspectorInfo>,
}