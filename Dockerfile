ARG GO_VERSION
ARG ALPINE_VERSION

################################################################################
# BUILDER/DEVELOPMENT IMAGE
################################################################################
FROM golang:${GO_VERSION}-alpine as builder

# Add git for downloading dependencies
RUN apk add --no-cache git gcc g++ libc-dev

WORKDIR /build

COPY go.mod go.sum ./

RUN go mod download

COPY main.go ./
COPY script/* ./script/

RUN go build

################################################################################
# FINAL IMAGE
################################################################################
FROM alpine:${ALPINE_VERSION}

ENV BUILD_DIR=/build

WORKDIR /app

RUN apk add --no-cache ca-certificates bash

COPY --from=builder $BUILD_DIR/ovh-ip-updater-go ${BUILD_DIR}/script/run.sh ./

RUN chmod +x run.sh

CMD ["./run.sh"]
