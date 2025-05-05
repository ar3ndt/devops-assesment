FROM golang:1.21 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

# Install goose
RUN go install github.com/pressly/goose/v3/cmd/goose@v3.13.0

# Copy all source files including config and migrations
COPY . .

# Build the app
RUN go build -o bank-app .

# Final runtime image
FROM debian:bookworm-slim

RUN adduser --disabled-password --gecos "" bankuser
WORKDIR /app

# Copy binary and goose
COPY --from=builder /app/bank-app .
COPY --from=builder /go/bin/goose /usr/local/bin/goose

# Copy the config and migrations folders
COPY --from=builder /app/config ./config
COPY --from=builder /app/db ./db

USER bankuser

EXPOSE 8080
CMD ["./bank-app"]
