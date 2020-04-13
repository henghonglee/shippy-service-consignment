FROM golang:alpine as builder

RUN echo http://mirror.yandex.ru/mirrors/alpine/v3.11/main > /etc/apk/repositories; \
    echo http://mirror.yandex.ru/mirrors/alpine/v3.11/community >> /etc/apk/repositories


RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN mkdir /app
WORKDIR /app

ENV GO111MODULE=on

COPY . .

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o shippy-service-consignment

# Run container
FROM alpine:latest

RUN echo http://mirror.yandex.ru/mirrors/alpine/v3.11/main > /etc/apk/repositories; \
    echo http://mirror.yandex.ru/mirrors/alpine/v3.11/community >> /etc/apk/repositories


RUN apk --no-cache add ca-certificates

RUN mkdir /app
WORKDIR /app
COPY --from=builder /app/shippy-service-consignment .

CMD ["./shippy-service-consignment"]
