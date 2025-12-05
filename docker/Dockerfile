# Multi-stage Dockerfile to build and run Facette
FROM golang:1.22-bullseye AS build

ARG FACETTE_VERSION
ENV CGO_ENABLED=0 GOOS=linux

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/facette/facette.git /src
WORKDIR /src
RUN if [ -n "$FACETTE_VERSION" ]; then git checkout "v${FACETTE_VERSION}"; fi
RUN go build -o /build/facette ./cmd/facette

FROM debian:12-slim

RUN useradd -r -s /usr/sbin/nologin facette

COPY --from=build /build/facette /usr/local/bin/facette
COPY facette.yaml /etc/facette/facette.yaml

RUN mkdir -p /var/log/facette /var/lib/facette /var/cache/facette  && chown -R facette:facette /var/log/facette /var/lib/facette /var/cache/facette

USER facette

EXPOSE 12003

ENTRYPOINT ["/usr/local/bin/facette","serve","--config","/etc/facette/facette.yaml"]
