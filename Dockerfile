# Stage 1: Build the application from source
ARG GO_VERSION=1.23.0
FROM golang:${GO_VERSION}-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy the source code from the build context
COPY ./filebrowser .

# Build the filebrowser binary statically
# -ldflags="-w -s" strips debug information to reduce binary size.
# CGO_ENABLED=0 creates a static binary.
RUN CGO_ENABLED=0 go build -v -o /filebrowser -ldflags="-w -s -X github.com/filebrowser/filebrowser/v2/version.Version=VERSION_ENV -X github.com/filebrowser/filebrowser/v2/version.CommitSHA=SHA_ENV" .

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