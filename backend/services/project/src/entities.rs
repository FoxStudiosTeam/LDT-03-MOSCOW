use schema::prelude::Project;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(ToSchema, Deserialize)]
pub struct GetProjectRequest {
    pub address : Option<String>,
    pub pagination : Option<Pagination>
}
#[derive(ToSchema, Deserialize)]
pub struct CreateProjectRequest {
    pub address : Option<String>,
    pub polygon : Option<String>,
    pub ssk : Option<String>
}

#[derive(ToSchema, Deserialize)]
pub struct UpdateProjectRequest {
    pub foreman : Option<String>,
    pub status : Option<i32>,
    pub uuid: String
}

#[derive(ToSchema, Deserialize)]
pub struct Pagination {
    pub offset : i32,
    pub limit : i32
}

#[derive(ToSchema,Deserialize)]
pub struct ActivateProjectRequest {
    pub uuid : Uuid
}
#[derive(ToSchema, Deserialize)]
pub struct AddIkoToProjectRequest {
    pub project_uuid : Uuid,
    pub iko_uuid : Uuid
}

#[derive(ToSchema, Deserialize)]
pub struct CreateProjectScheduleRequest {
    pub start_date : chrono::NaiveDate,
    pub end_date :  chrono::NaiveDate,
    pub project_uuid : Uuid
}

#[derive(ToSchema, Deserialize)]
pub struct AddWorkToScheduleRequest {
    pub created_by : Uuid,
    pub work_uuid : Uuid, 
    pub start_date : chrono::NaiveDate,
    pub end_date : chrono::NaiveDate,
    pub target_volume : f64,
    pub is_draft : bool
}

#[derive(ToSchema, Deserialize)]
pub struct UpdateWorkScheduleRequest {
    pub items : Vec<UpdateWorksInScheduleRequest>
}

#[derive(ToSchema,Deserialize)]
pub struct UpdateWorksInScheduleRequest {
    pub start_date : chrono::NaiveDate,
    pub end_date : chrono::NaiveDate,
    pub uuid : Uuid
}

#[derive(ToSchema, Deserialize)]
pub struct GetProjectScheduleRequest{
    pub uuid : Uuid
}
#[derive(ToSchema, Serialize)]
pub struct GetProjectScheduleResponse {
    pub items : Vec<ProjectScheduleCategoryPartResponse>
}

#[derive(ToSchema, Serialize)]
pub struct ProjectScheduleCategoryPartResponse {
    pub title: String,
    pub items: Option<Vec<ProjectScheduleItemResponse>>,
}

#[derive(ToSchema, Serialize)]
pub struct ProjectScheduleItemResponse {
    pub title: String,
    pub start_date: chrono::NaiveDate,
    pub end_date: chrono::NaiveDate,
}

// ProjectStatus - таблица статусов проекта.
#[repr(i32)]
#[derive(Debug, Clone, Copy)]
pub enum ProjectStatus {
    New,
    InActive, 
    Suspend,
    Normal,
    LowPunishment,
    NormalPunishment,
    HighPunishment,
    SomeWarnings
}

impl TryFrom<i32> for ProjectStatus {
    type Error = ();

    fn try_from(v: i32) -> Result<Self, Self::Error> {
        match v {
            x if x == ProjectStatus::New as i32 => Ok(ProjectStatus::New),
            x if x == ProjectStatus::InActive as i32 => Ok(ProjectStatus::InActive),
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