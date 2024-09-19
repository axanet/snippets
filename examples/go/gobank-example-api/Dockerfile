# Stage 1: Development
FROM golang:1.22.5 AS development

WORKDIR /gobank

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go install github.com/cespare/reflex@latest

EXPOSE 8080

CMD ["reflex", "-g", "*.go", "go", "run", "main.go", "--start-service"]

# Stage 2: Builder
FROM golang:1.22.5 AS builder

WORKDIR /gobank

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o gobank

# Stage 3: Production
FROM alpine:latest AS production

WORKDIR /gobank

COPY --from=builder /gobank/gobank /gobank/gobank
COPY .env .env

EXPOSE 9090

CMD ["/gobank/gobank", "--seed", "--docker"]
