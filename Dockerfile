FROM rust:bookworm AS rustbuilder
ARG AMARU_VERSION=main
ENV AMARU_VERSION=${AMARU_VERSION}
WORKDIR /code
RUN echo "Building Amaru..." \
    && apt-get update -y && apt-get install -y libclang-dev \
    && git clone https://github.com/pragma-org/amaru.git \
    && cd amaru \
    && cargo build --release

FROM ghcr.io/blinklabs-io/cardano-configs:20250812-1 AS cardano-configs

FROM debian:bookworm-slim AS amaru
COPY --from=rustbuilder /code/amaru/data/ /data/
COPY --from=rustbuilder /code/amaru/target/release/amaru /bin/
COPY --from=cardano-configs /config/ /opt/cardano/config/
RUN apt-get update -y \
    && apt-get install -y \
       ca-certificates \
       libssl3 \
       llvm-14-runtime \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /data
ENTRYPOINT ["/bin/amaru"]
