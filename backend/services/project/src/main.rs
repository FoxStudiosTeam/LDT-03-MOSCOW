use std::sync::Arc;

use axum::http::StatusCode;
use axum::routing::get;
use axum_extra::TypedHeader;
use axum_extra::headers::Authorization;
use axum_extra::headers::authorization::Basic;
use axum_prometheus::PrometheusMetricLayer;
use tower::ServiceBuilder;
use tracing::*;
use utils::env_config;
use utoipa::OpenApi;
use utoipa_axum::router::{OpenApiRouter};

// Some useful things
use shared::prelude::*;
use utoipa_axum::routes;
use utoipa_scalar::{Scalar, Servable};

use crate::services::{IProjectScheduleService, IProjectService, IWorkCategoryService, IWorkService};

mod controllers;
mod services;
mod entities;

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

pub const MAIN_TAG: &str = "project";

#[derive(OpenApi)]
#[openapi(
    modifiers(&SecurityAddon),
    tags(
        (name = MAIN_TAG, description = "API"),
    )
)]

struct ApiDoc;

pub type DB = sqlx::Postgres;
pub type Orm = orm::prelude::Orm<sqlx::Pool<DB>>;


#[derive(Default, Clone)]
struct AppState {
    orm: Option<Orm>,
    project_service: Option<Arc<dyn IProjectService>>,
    project_schedule_service: Option<Arc<dyn IProjectScheduleService>>,
    work_category_service: Option<Arc<dyn IWorkCategoryService>>,
    work_service : Option<Arc<dyn IWorkService>>
} 

impl AppState {
    fn orm(&self) -> &Orm {
        self.orm.as_ref().expect("Orm is not initialized")
    }
    fn orm_mut(&mut self) -> &mut Orm {
        self.orm.as_mut().expect("Orm is not initialized")
    }
    fn project_service(&self) -> &Arc<dyn IProjectService> {
        self.project_service.as_ref().expect("Project Service is not initialized")
    }
    fn project_schedule_service(&self) -> &Arc<dyn IProjectScheduleService> {
        self.project_schedule_service.as_ref().expect("ProjectScheduleService is not initialized")
    }
    fn work_category_service(&self) -> &Arc<dyn IWorkCategoryService> {
        self.work_category_service.as_ref().expect("WorkCategoryService is not initialized")
    }
    fn work_service(&self) -> &Arc<dyn IWorkService> {
        self.work_service.as_ref().expect("WorkService is not initialized")
    }
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

    let mut state = AppState::default();
    let orm = Orm::new(pg);
    state.orm = Some(orm);

    let project_service = services::new_project_service(state.clone());
    state.project_service = Some(project_service);
    
    let project_schedule_service = services::new_project_schedule_service(state.clone());
    state.project_schedule_service = Some(project_schedule_service);

    let work_category_service = services::new_work_category_service(state.clone());
    state.work_category_service = Some(work_category_service);

    let work_service = services::new_work_service(state.clone());
    state.work_service = Some(work_service);

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
        .nest("/api/project", 
            OpenApiRouter::new()
                .routes(
                    routes!(
                        controllers::handle_get_project,
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_create_project
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_update_project
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_activate_project
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_add_iko_to_project
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_create_project_schedule
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_add_work_to_schedule
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_update_works_in_schedule
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_update_work_in_schedule
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_get_project_schedule
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_create_work_category
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_get_work_categories
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_update_work_category
                    )
                )
                .routes(
                    routes!(
                        controllers::handle_get_kpgz_vec
                    )
                )
                .routes (
                    routes!(
                        controllers::handle_save_work
                    )
                )
                .routes (
                    routes!(
                        controllers::handle_get_works_by_category
                    )
                )
                .routes (
                    routes!(
                        controllers::handle_get_project_statuses
                    )
                )
                //.layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
                .with_state(state)
        )
        // .routes(
        //     routes!(
        //         secured_route
        //     ).layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
        // )
        // .routes(
        //     routes!(
        //         role_secured_route
        //     )
        //     .layer(auth_jwt::prelude::AuthLayer::new(Role::Operator | Role::Inspector))
        //     .layer(axum::middleware::from_fn(auth_jwt::prelude::token_extractor))
        // )
        .split_for_parts();
    
    let app = axum::Router::new()
        .merge(Scalar::with_url("/api/project/docs/scalar", api))
        .merge(metrics)
        .merge(api_router)
        .layer(shared::helpers::cors::cors_layer())
        .layer(default_layers);

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{}", CFG.PORT)).await
        .inspect_err(|err| tracing::error!("Failed to bind to port {}: {}", CFG.PORT, err))?;

    info!("Listening on 0.0.0.0:{}", CFG.PORT);
    info!(
        "Try scalar docs on http://127.0.0.1:{}/api/project/docs/scalar",
        CFG.PORT
    );
    axum::serve(listener, app.into_make_service()).await?;
    Ok(())
}
