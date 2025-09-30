use axum::{http::StatusCode, response::{IntoResponse, Response}, Json};
use tracing::error;
use serde::Serialize;
use utoipa::ToSchema;

pub struct AppErr(pub anyhow::Error, pub Option<StatusCode>, pub Option<Response>);

impl AppErr {
    pub fn default() -> Self {
        AppErr(
            anyhow::Error::msg("Error"),
            None,
            None
        )
    }
    /// you can use anyhow::anyhow! to convert almost any to anyhow::Error.
    pub fn new(error: anyhow::Error, status: Option<StatusCode>, response: Option<Response>) -> Self {
        AppErr(error, status, response)
    }
    /// you can use anyhow::anyhow! to convert almost any to anyhow::Error.
    pub fn err_from_new<T>(error: anyhow::Error, status: Option<StatusCode>, response: Option<Response>) -> Result<T, Self> {
        Err(Self::new(error, status, response))
    }
    pub fn from_msg(msg: &str) -> Self {
        AppErr(anyhow::anyhow!("{msg}"), None, None)
    }
    pub fn err_from_msg<T>(msg: &str) -> Result<T, Self> {
        Err(Self::from_msg(msg))
    }
    pub fn with_status(mut self, status: StatusCode) -> Self {
        self.1 = Some(status);
        self
    }
    pub fn with_response(mut self, response: impl IntoResponse) -> Self {
        self.2 = Some(response.into_response());
        self
    }
    pub fn with_err_response(mut self, msg: &str) -> Self {
        self.2 = Some((StatusCode::INTERNAL_SERVER_ERROR, Json(ErrorWrapper{message : msg.to_string()})).into_response());
        self
    }
}

impl ToString for AppErr {
    fn to_string(&self) -> String {
        self.0.to_string()
    }
}


impl IntoResponse for AppErr {
    fn into_response(self) -> axum::response::Response {
        // Error will appear in logs on response
        error!("{}", self.0);
        (
            self.1.unwrap_or(StatusCode::INTERNAL_SERVER_ERROR),
            self.2.unwrap_or((StatusCode::INTERNAL_SERVER_ERROR, Json(ErrorWrapper{message : "Internal server error :P".to_string()})).into_response()),
        ).into_response()
    }
}

#[derive(Serialize, ToSchema)]
pub struct ErrorWrapper {
    pub message : String
}

impl<E> From<E> for AppErr
where
    E: Into<anyhow::Error>,
{
    fn from(err: E) -> Self {
        Self(err.into(), None, None)
    }
}

pub trait IntoAppErr<T> {
    fn into_app_err(self) -> Result<T, AppErr>;
}

impl<T, E> IntoAppErr<T> for Result<T, E>
where E: ToString,
{
    fn into_app_err(self) -> Result<T, AppErr> {
        match self {
            Ok(t) => Ok(t),
            Err(e) => Err(AppErr(anyhow::anyhow!(e.to_string()), None, None))
        }
    }
}