FROM lukemathwalker/cargo-chef:latest-rust-1 AS chef
WORKDIR /build

FROM chef AS planner

ARG SERVICE_NAME=unspecified

COPY ./Cargo.toml ./Cargo.lock ./
COPY ./backend/libs ./backend/libs
COPY ./backend/services/$SERVICE_NAME ./backend/services/$SERVICE_NAME

RUN find ./backend/libs ./backend/services/$SERVICE_NAME -name Cargo.toml -execdir sh -c 'mkdir -p src && echo "fn main() {println!("Dummy")}" > src/main.rs' \;

# full dummy schema_gen
RUN mkdir -p ./backend/.schema_gen/src && \
    echo "" > ./backend/.schema_gen/src/lib.rs && \
    echo '[package]\nversion="0.1.0"\nname="schema_gen"\nedition = "2024"' > ./backend/.schema_gen/Cargo.toml

RUN --mount=type=ssh cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

ARG SERVICE_NAME=unspecified

COPY --from=planner /build/recipe.json ./recipe.json

RUN apt-get update && apt-get install -y mold cmake
ENV RUSTFLAGS="-C link-arg=-fuse-ld=mold"

# --release
RUN --mount=type=ssh cargo chef cook --recipe-path recipe.json

COPY ./backend/libs ./backend/libs
COPY ./backend/services/$SERVICE_NAME ./backend/services/$SERVICE_NAME
COPY ./Cargo.toml ./Cargo.lock ./

# --release
RUN --mount=type=ssh cargo build --bin $SERVICE_NAME -F certs_in_env

FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y libssl3 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/bin

ARG SERVICE_NAME=unspecified
COPY --from=builder /build/target/release/$SERVICE_NAME /usr/local/bin/artifact

ENTRYPOINT ["/usr/local/bin/artifact"]