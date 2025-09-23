#[macro_export]
macro_rules! router {
    (
        $(
            $root:literal: ($($layer:expr)*) => {
                $(
                    $method:ident $path:literal -> $handler:ident $(($perm:expr))?
                )*
            } 
        )*
    ) => {{
        let mut router = axum::Router::new();
        $(
            let mut nested_router = axum::Router::new();
            $(
                let mut route = axum::routing::$method($handler);
                $(
                    route = route.layer($p.build($perm).await?);
                )?
                nested_router = nested_router.route($path, route);
            )*
            $(
                nested_router = nested_router.layer($layer);
            )*
            router = router.nest($root, nested_router);
        )*
        router
    }};
}
