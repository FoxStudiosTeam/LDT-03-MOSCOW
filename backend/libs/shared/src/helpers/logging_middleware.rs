use axum::{body::Body, http::{Request, Response}, middleware::Next};
use tracing::{Instrument, Span, info};



pub async fn unique_span_layer(req: Request<Body>, next: Next) -> Response<Body> {
    let id = format!("\x1b[90m{}\x1b[0m", uuid::Uuid::new_v4().simple());
    let span = tracing::info_span!("", "id" = %id);
    next.run(req).instrument(span).await
}

pub async fn logging_middleware(req: Request<Body>, next: Next) -> Response<Body> {
    let span = Span::current();
    info!("Received request on: {}", req.uri().to_string());
    let response = next.run(req).instrument(span).await;
    info!("Response status: {:?}", response.status());
    response
}