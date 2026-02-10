# -- GO BUILD ------------------------------------------------------------------

FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS gobuild

WORKDIR /go/src/github.com/kubernetes-sigs/external-dns

COPY go.mod .
COPY go.sum .

RUN go mod download

RUN apk --update upgrade \
    && apk --no-cache --no-progress add make git mercurial bash gcc musl-dev curl tar ca-certificates tzdata \
    && update-ca-certificates

COPY . .

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

SHELL ["bash", "-c"]

RUN if [ "${TARGETARCH}" = "amd64" ]; then \
        VERSION="$(git describe --tags --always)" GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOAMD64=${TARGETVARIANT} make build.amd64; \
    elif [ "${TARGETARCH}" = "arm" ]; then \
        VERSION="$(git describe --tags --always)" GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT} make build.arm/v7; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
        VERSION="$(git describe --tags --always)" GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM64=${TARGETVARIANT} make build.arm64; \
    else \
        echo "Unsupported architecture: ${TARGETARCH}"; exit 1; \
    fi

# -- scratch -------------------------------------------------------------------

FROM scratch

ARG TARGETPLATFORM

COPY --from=gobuild /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=gobuild /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=gobuild /etc/passwd /etc/passwd
COPY --from=gobuild /etc/group /etc/group
COPY --from=gobuild /etc/services /etc/services

COPY --from=gobuild /go/src/github.com/kubernetes-sigs/external-dns/build/external-dns /

EXPOSE 7979
VOLUME ["/tmp"]

ENTRYPOINT ["/external-dns"]
