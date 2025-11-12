ARG ALPINE_VERSION=3.22.0

FROM alpine:${ALPINE_VERSION}

ARG UID
ARG GID
ARG USER
ARG GROUP
ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}
ENV GROUP=${GROUP}

# Setup unique user and group - needs bash
RUN apk add --no-cache bash

# Create user and group
RUN addgroup -S --gid ${GID} ${GROUP} \
    && adduser -S --uid ${UID} ${USER} -s /bin/sh -G ${GROUP} ${USER} \
    && apk add --no-cache sudo \
    && chmod u+s /bin/su \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install main packages and remove default server definition
RUN apk add --no-cache \
  openrc \
  curl \
  wget \
  openssl \
  nginx \
  zip \
  nano \
  git \
  #ffmpeg \
  musl-dev \
  libva-dev \
  libffi-dev \
  openssl-dev \
  # build-essential
  build-base \
  supervisor \
  # Python
  python3 \
  py3-pip

# Configure NGINX and remove created its default html directory
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/conf.d /etc/nginx/conf.d/

# Configure Supervisord
COPY config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY config/supervisor/conf.d/. /etc/supervisor/conf.d/

# Create project root and set it as work directory
RUN mkdir -p /var/www
WORKDIR /var/www

# Add application from docker-compose.yml -> volumes: source
COPY --chown=${USER}:${GROUP} ../ /var/www

# Remove unused directories
RUN rm -rf /var/www/html /var/www/localhost

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R ${USER}:${GROUP} /var/www /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
USER ${USER}

# Container ports
EXPOSE 80 443 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]