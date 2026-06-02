FROM alpine:latest

RUN apk add --no-cache \
    ca-certificates \
    curl \
    unzip

RUN cd /tmp && \
    curl -L https://github.com/pocketbase/pocketbase/releases/download/v0.22.12/pocketbase_0.22.12_linux_amd64.zip -o pb.zip && \
    unzip pb.zip && \
    rm pb.zip && \
    cp /tmp/pocketbase /usr/local/bin/pocketbase && \
    chmod +x /usr/local/bin/pocketbase && \
    mkdir -p /pb/pb_data

WORKDIR /pb

EXPOSE 8090

CMD ["pocketbase", "serve", "--http=0.0.0.0:8090"]
