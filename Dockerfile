FROM rust:1.84 AS builder

# Install wasm32-unknown-unknown target
RUN rustup target add wasm32-unknown-unknown

# Install trunk
RUN cargo install trunk

WORKDIR /insagenda

COPY . .

# Build frontend
RUN cd ./web-api && cargo build --release
# Build frontend
RUN cd ./web-app && trunk build --public-url=agenda --release

FROM debian:bookworm-slim

RUN apt-get update && apt install -y sqlite3 ca-certificates nginx && rm -rf /var/lib/apt/lists/*

WORKDIR /insagenda

COPY --from=builder /insagenda/web-api/target/release/web-api ./web-api
COPY --from=builder /insagenda/web-app/dist ./web-app/dist

CMD ["./web-api"]

