# Stage 1 - build
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
ENV PROWLARRVERSION="2.4.0.5397"
# install bash + node/yarn for frontend build
RUN apk add --no-cache bash nodejs npm

WORKDIR /src
COPY . .

# install yarn globally (needed for lint & webpack)
RUN npm install -g yarn

# build backend + frontend + packages (no installer)
RUN bash ./build.sh --backend --frontend --packages -f net8.0 -r linux-musl-x64

# Stage 2 - runtime
FROM ghcr.io/linuxserver/baseimage-alpine:3.22

ENV XDG_CONFIG_HOME="/config/xdg" \
  COMPlus_EnableDiagnostics=0 \
  TMPDIR=/run/prowlarr-temp

# runtime deps for dotnet apps
RUN \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet
RUN mkdir -p /app/prowlarr/bin
WORKDIR /app/prowlarr

# copy packaged linux-musl-x64 build from stage 1
COPY --from=build /src/_artifacts/linux-musl-x64/net8.0/Prowlarr/ ./

EXPOSE 9696
VOLUME /config

# s6 service
RUN mkdir -p /etc/services.d/prowlarr
COPY <<EOF /etc/services.d/prowlarr/run
#!/usr/bin/with-contenv bash
exec /app/prowlarr/Prowlarr -nobrowser -data=/config
EOF

RUN chmod +x /etc/services.d/prowlarr/run

