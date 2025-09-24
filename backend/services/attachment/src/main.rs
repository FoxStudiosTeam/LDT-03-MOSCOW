use aws_config::{BehaviorVersion, Region};
use aws_sdk_s3::{config::{Credentials, SharedCredentialsProvider}};
use axum::http::StatusCode;
use axum::routing::get;
use axum_extra::TypedHeader;
use axum_extra::headers::Authorization;
use axum_extra::headers::authorization::Basic;
use axum_prometheus::PrometheusMetricLayer;
use sqlx::Postgres;
use tower::ServiceBuilder;
use tracing::*;
use utils::env_config;
use utoipa::OpenApi;
use utoipa_axum::router::{OpenApiRouter};

mod api;
mod multipart;
mod state;

// Some useful things
use shared::prelude::*;
use utoipa_scalar::{Scalar, Servable};

use crate::state::AppState;

// Hover to see docs
env_config!(
    ".env" => pub(crate) ENV = pub(crate) Env {
        DB_URL: String,
        METRICS_USERNAME: String,
        METRICS_PASSWORD: String,
        S3_URL: String,
        S3_KEY: String,
        S3_SECRET: String,
        S3_BUCKET: String
    }
    ".cfg" => pub(crate) CFG = pub(crate) Cfg {
        PORT: u16 = 4001,
    }
);

pub const MAIN_TAG: &str = "attachment";

#[derive(OpenApi)]
#[openapi(
    modifiers(&SecurityAddon),
    tags(
        (name = MAIN_TAG, description = "API"),
    )
)]

struct ApiDoc;

pub type DB = Postgres;
pub type Orm = orm::prelude::Orm<sqlx::Pool<DB>>;


#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::new("debug"))
        .init();

    info!("Connecting to DB");
    let pg = sqlx::postgres::PgPoolOptions::new()
        .max_connections(5)
        .connect(&ENV.DB_URL)
        .await
        .inspect_err(|e| info!("Can't connect to db: {e}"))?;
    info!("Connected to DB");
    
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

    let orm = orm::prelude::Orm::new(pg);
    let state = AppState{orm, s3: client};

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
        .nest("/api", api::router(state))
        .split_for_parts();
    
    let app = axum::Router::new()
        .merge(Scalar::with_url("/docs/scalar", api))
        .merge(api_router)
        .merge(metrics)
        .layer(default_layers);

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{}", CFG.PORT)).await
        .inspect_err(|err| tracing::error!("Failed to bind to port {}: {}", CFG.PORT, err))?;

    info!("Listening on 0.0.0.0:{}", CFG.PORT);
    info!(
        "Try scalar docs on http://127.0.0.1:{}/docs/scalar",
        CFG.PORT
    );
    axum::serve(listener, app.into_make_service()).await?;
    Ok(())
}