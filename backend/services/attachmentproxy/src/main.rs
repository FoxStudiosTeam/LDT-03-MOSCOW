use aws_config::{BehaviorVersion, Region};
use axum::{
    body::Body,
    extract::{Path, Query, State},
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
    routing::get,
};
use aws_sdk_s3::{Client, config::{Credentials, SharedCredentialsProvider}};
use axum_extra::TypedHeader;
use axum_extra::headers::Authorization;
use axum_extra::headers::authorization::Basic;
use axum_prometheus::PrometheusMetricLayer;
use shared::prelude::*;
use tokio_util::io::ReaderStream;
use tower::ServiceBuilder;
use tracing::info;
use utils::env_config;
use utoipa::*;
use utoipa_scalar::{Scalar, Servable};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};


#[derive(Clone)]
struct AppState {
    s3: Client,
}

#[derive(IntoParams, ToSchema, serde::Deserialize)]
pub struct RequestParams {
    pub file_id: uuid::Uuid,
    pub resource_id: uuid::Uuid
}

#[utoipa::path(
    get,
    path = "/file/",
    params(RequestParams),
    tag = crate::MAIN_TAG,
    request_body(description = "Multipart file", content_type = "multipart/form-data"),
    responses(
        (status = 200, description = "Success"),
        (status = 401, description = "Unauthorized"),
        (status = 404, description = "Not Found"),
    )
)]
async fn proxy_file(
    State(state): State<Arc<AppState>>,
    Query(RequestParams{resource_id, file_id}): Query<RequestParams>,
    headers: HeaderMap,
) -> impl IntoResponse {
    let resp = match state.s3.get_object().bucket(&ENV.S3_BUCKET).key(&format!("attachments/{}/{}", resource_id, file_id)).send().await {
        Ok(r) => r,
        Err(_e) => {
            return (StatusCode::NOT_FOUND, "not found").into_response();
        }
    };

    let byte_stream = resp.body;

    let async_read = byte_stream.into_async_read();
    let reader_stream = ReaderStream::new(async_read);

    let body = Body::from_stream(reader_stream);


    let mut response = (StatusCode::OK, body).into_response();

    if let Some(ct) = resp.content_type {
        if let Ok(header_val) = ct.parse() {
            response.headers_mut().insert("content-type", header_val);
        }
    }

    response
}


env_config!(
    ".env" => pub(crate) ENV = pub(crate) Env {
        METRICS_USERNAME: String,
        METRICS_PASSWORD: String,
        S3_URL: String,
        S3_KEY: String,
        S3_SECRET: String,
        S3_BUCKET: String
    }
    ".cfg" => pub(crate) CFG = pub(crate) Cfg {
        PORT: u16 = 4000,
    }
);

pub const MAIN_TAG: &str = "attachment proxy";

#[derive(OpenApi)]
#[openapi(
    modifiers(&SecurityAddon),
    tags(
        (name = MAIN_TAG, description = "API"),
    )
)]
struct ApiDoc;


#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::new("debug"))
        .init();

    info!("Connecting to s3");
    let creds = SharedCredentialsProvider::new(Credentials::new(
        &ENV.S3_KEY,
        &ENV.S3_SECRET,
        None,
        None,
        "provider",
    ));

    let config = aws_config::SdkConfig::builder()
        .credentials_provider(creds)
        .endpoint_url(ENV.S3_URL.clone())
        .behavior_version(BehaviorVersion::latest())
        .region(Region::new("eu-north-1"))
        .build();

    let client = aws_sdk_s3::Client::new(&config);

    let state = AppState{s3: client};

    let (prometheus_layer, metric_handle) = PrometheusMetricLayer::pair();

    let default_layers = ServiceBuilder::new()
        .layer(axum::middleware::from_fn(unique_span_layer))
        .layer(axum::middleware::from_fn(logging_middleware))
        .layer(prometheus_layer)
        .layer(tower_http::catch_panic::CatchPanicLayer::new());

    let metrics = axum::Router::new().route(
        "/metrics",
        get(move |TypedHeader(auth): TypedHeader<Authorization<Basic>>| async move {
            if auth.username() == ENV.METRICS_USERNAME && auth.password() == ENV.METRICS_PASSWORD {
                Ok::<_, StatusCode>(metric_handle.render())
            } else {
                Err(StatusCode::UNAUTHORIZED)
            }
        }),
    );


    let (api_router, api) = OpenApiRouter::with_openapi(ApiDoc::openapi())
        .routes(routes!(proxy_file))
        .with_state(Arc::new(state))
        .split_for_parts();
    
    let app = axum::Router::new()
        .merge(Scalar::with_url("/api/attachmentproxy/docs/scalar", api))
        .merge(api_router)
        .merge(metrics)
        .layer(shared::helpers::cors::cors_layer())
        .layer(default_layers);


    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{}", CFG.PORT)).await
        .inspect_err(|err| tracing::error!("Failed to bind to port {}: {}", CFG.PORT, err))?;

    info!("Listening on 0.0.0.0:{}", CFG.PORT);
    info!(
        "Try scalar docs on http://127.0.0.1:{}/api/attachmentproxy/docs/scalar",
        CFG.PORT
    );
    axum::serve(listener, app.into_make_service()).await?;
    Ok(())
}
