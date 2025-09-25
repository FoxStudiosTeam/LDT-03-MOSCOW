use axum::http::StatusCode;
use axum::routing::get;
use axum_extra::TypedHeader;
use axum_extra::headers::Authorization;
use axum_extra::headers::authorization::Basic;
use axum_prometheus::PrometheusMetricLayer;
use sqlx::{Pool, Postgres};
use tower::ServiceBuilder;
use tracing::*;
use utils::env_config;
use utoipa::OpenApi;
use utoipa_axum::router::{OpenApiRouter};
mod api;
mod helpers;

use orm::prelude::*;
// Some useful things
use shared::prelude::*;
use utoipa_scalar::{Scalar, Servable};

// Hover to see docs
env_config!(
    ".env" => pub(crate) ENV = pub(crate) Env {
        DB_URL: String,
        METRICS_USERNAME: String,
        METRICS_PASSWORD: String,
    }
    ".cfg" => pub(crate) CFG = pub(crate) Cfg {
        PORT: u16 = 4000,
    }
);

pub const MAIN_TAG: &str = "punishment";

#[derive(OpenApi)]
#[openapi(
    modifiers(&SecurityAddon),
    tags(
        (name = MAIN_TAG, description = "API"),
    )
)]

struct ApiDoc;

#[derive(Clone)]
pub struct AppState{
    pub orm: Orm<Pool<Postgres>>,
}

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

    let orm = orm::prelude::Orm::new(pg);
    let state = AppState{orm};

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
        .nest("/api/punishment", api::make_router(state.clone()))
        .split_for_parts();

    let cors = tower_http::cors::CorsLayer::new()
        .allow_origin("http://localhost:3000".parse::<axum::http::HeaderValue>()?)
        .allow_methods(tower_http::cors::Any)
        .allow_headers(tower_http::cors::Any)
        .max_age(std::time::Duration::from_secs(3600));
    
    let app = axum::Router::new()
        .merge(Scalar::with_url("/docs/scalar", api))
        .merge(metrics)
        .merge(api_router)
        .layer(cors)
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

