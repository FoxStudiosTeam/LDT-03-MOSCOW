use tower_http::cors::CorsLayer;

pub fn cors_layer() -> CorsLayer {
    CorsLayer::new()
        .allow_origin("http://localhost:3000".parse::<axum::http::HeaderValue>().expect("Invalid origin"))
        .allow_methods(tower_http::cors::Any)
        .allow_headers(tower_http::cors::Any)
        .allow_credentials(true)
        .max_age(std::time::Duration::from_secs(3600))
}