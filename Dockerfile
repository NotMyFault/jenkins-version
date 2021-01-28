FROM --platform=${BUILDPLATFORM} golang:1.15-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG TARGETPLATFORM

WORKDIR /go/src/app
COPY . .

ARG version
ARG build_date
ARG sha

ENV CGO_ENABLED=0

RUN go version

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -v -a \
  -ldflags "-w -s \
    -X github.com/garethjevans/jenkins-version/pkg/version.BuildDate=$build_date \
    -X github.com/garethjevans/jenkins-version/pkg/version.Version=$version \
    -X github.com/garethjevans/jenkins-version/pkg/version.Sha1=$sha" \
  -o bin/jv cmd/jv/jv.go

FROM --platform=${BUILDPLATFORM} alpine:3.13.0

LABEL maintainer="Gareth Evans <gareth@bryncynfelin.co.uk>"
COPY --from=builder /go/src/app/bin/jv /usr/bin/jv

ENTRYPOINT [ "/usr/bin/jv" ]

CMD ["--help"]
