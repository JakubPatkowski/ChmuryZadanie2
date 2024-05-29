# syntax = docker/dockerfile:experimental
# ustawienie ekperymentalnej składni Dockefile

# --------- ETAP 1 -------------------------

# Ustawienie obrazu bazowego jako 'scratch' (pusty obraz)
FROM scratch as builder

# Dodanie zawartości Alpine Linux do obrazu
ADD alpine-minirootfs-3.20.0-x86_64.tar.gz /

LABEL maintainer="Jakub Patkowski"

# dodanie git
RUN apk add git 

# Klonowanie repozytorium z GitHuba za pomocą git i ustawienie uprawnień dla użytkownika 'node'
RUN --mount=type=ssh git clone https://github.com/JakubPatkowski/ChmuryZadanie1 && \
    addgroup -S node && \
    adduser -S node -G node && \
    rm -rf /var/cache/apk

# Ustawienie użytkownika 'node' jako domyślnego użytkownika dla polecenia RUN i COPY
USER node

# Ustawienie katalogu roboczego dla użytkownika 'node'
WORKDIR /home/node/app

# Skopiowanie pliku 'server.js' do katalogu roboczego
COPY --chown=node:node server.js .


# --------- ETAP 2 ------------------------
# Ustawienie obrazu bazowego jako 'node:iron-alpine3.20'
#  FROM node:12.16.3-alpine3.11
FROM node:iron-alpine3.20

# Zdefiniowanie zmiennej srodowiskowej 'VERSION' z domyślną wartością 'v1.0.0'
ARG VERSION

ENV VERSION=${VERSION:-v1.0.0}

# Instalacja git i curl w obrazie
RUN apk add --no-cache git && \ 
    apk update && \
    apk upgrade && \
    apk add --no-cache curl

# Ustawienie użytkownika 'node' jako domyślnego użytkownika dla polecenia RUN i COPY
USER node

# Utworzenie katalogu '/home/node/app' 
RUN mkdir -p /home/node/app

# Ustawienie katalogu roboczego dla użytkownika 'node'
WORKDIR /home/node/app

# Skopiowanie pliku 'server.js' z etapu 1 do katalogu roboczego
COPY --from=builder --chown=node:node /home/node/app/server.js ./server.js

# Ustawienie portu, który zostanie wystawiony
EXPOSE 3000

# Konfiguracja testu stanu aplikacji
HEALTHCHECK --interval=4s --timeout=20s --start-period=2s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1
    
# Ustawienie punktu wejściowego dla kontenera
ENTRYPOINT ["node", "server.js"]
