FROM alpine as builder

RUN apk add --no-cache --update wget

RUN mkdir -p /go
WORKDIR /go

RUN wget "https://github.com/lncm/invoicer/releases/download/v0.0.11/invoicer-linux-arm" \
    && chmod 755 invoicer-linux-arm 

# Start a new, final image.
FROM alpine as final

# Add bash and ca-certs, for quality of life and SSL-related reasons.
RUN apk --no-cache add \
    bash \
    ca-certificates

# Create directory for data assets
RUN mkdir -p /invoicer-data
RUN mkdir -p /invoicer-data/static

WORKDIR /invoicer-data

# Copies index.html file into
COPY static/index.html /invoicer-data/static.html

# Copy the binaries from the builder image.
COPY --from=builder /go/invoicer-linux-arm /bin/
COPY entrypoint-invoicer.sh /bin/

# Expose lnd ports (p2p, rpc).
EXPOSE 1666

# Invoicer Entrypoint
CMD ["entrypoint-invoicer.sh"]
