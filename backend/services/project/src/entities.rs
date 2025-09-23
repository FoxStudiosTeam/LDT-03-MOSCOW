use serde::Deserialize;
use utoipa::ToSchema;

#[derive(ToSchema, Deserialize)]
pub struct GetProjectRequest {
    pub address : Option<String>,
}