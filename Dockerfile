# Stage 1: Build the application from source
ARG GO_VERSION=1.22
ARG VERSION=unknown
ARG COMMIT_SHA=unknown
FROM golang:${GO_VERSION}-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy the source code from the build context
COPY ./filebrowser .

# Build the filebrowser binary statically
# -ldflags="-w -s" strips debug information to reduce binary size.
# CGO_ENABLED=0 creates a static binary, which is ideal for Alpine.
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o /filebrowser -ldflags="-w -s -X github.com/filebrowser/filebrowser/v2/version.Version=${VERSION} -X github.com/filebrowser/filebrowser/v2/version.CommitSHA=${COMMIT_SHA}" .

# Stage 2: Create the final, minimal image
FROM busybox:musl

# Copy the static binary from the builder stage
COPY --from=builder /filebrowser /usr/local/bin/filebrowser
COPY ./content ./

WORKDIR /config

# Create the default data directory
RUN mkdir -p /srv 

VOLUME /srv /config

# Expose the default filebrowser port
EXPOSE 80

# Set the entrypoint to run filebrowser
ENTRYPOINT ["sh", "/entrypoint.sh"]