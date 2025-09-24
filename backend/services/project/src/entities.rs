use axum::{http::{Response, StatusCode}, response::IntoResponse};
use schema::prelude::Project;
use serde::{Deserialize, Serialize};
use shared::prelude::AppErr;
use utoipa::ToSchema;

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
    pub status : Option<i32>
}

#[derive(ToSchema, Deserialize)]
pub struct Pagination {
    pub offset : i32,
    pub limit : i32
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
    pub total: i32
}