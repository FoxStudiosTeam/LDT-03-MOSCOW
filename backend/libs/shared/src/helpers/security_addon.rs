use utoipa::{Modify, openapi::security::{ApiKey, ApiKeyValue, Http, SecurityScheme}};

pub struct SecurityAddon;

impl Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        let components = openapi.components.as_mut().unwrap();

        components.add_security_scheme(
            "bearer_access",
            SecurityScheme::Http(
                Http::builder()
                    .scheme(utoipa::openapi::security::HttpAuthScheme::Bearer)
                    .bearer_format("JWT")
                    .description(Some("Access token in Authorization header"))
                    .build()
            ),
        );

        components.add_security_scheme(
            "query_access",
            SecurityScheme::ApiKey(ApiKey::Query(ApiKeyValue::with_description("token", "Access token in query parameter")))
        );
    }
}