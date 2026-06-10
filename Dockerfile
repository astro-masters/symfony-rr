FROM ghcr.io/roadrunner-server/roadrunner:2025.1.14 AS roadrunner
FROM composer:2 AS composer

FROM php:8.4-cli AS base

ARG APP_UID=1000
ARG APP_GID=1000
ARG CONTAINER_USER=app

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
     wget \
     acl \
     cron \
     git \
     libfreetype6-dev \
     libjpeg-dev \
     libpng-dev \
     libwebp-dev \
     libpq-dev \
     pkg-config \
     libzip-dev \
     libicu-dev \
     libxslt1-dev \
     libxml2-dev \
     libonig-dev \
     unzip \
     zip \
     debian-keyring \
     debian-archive-keyring \
     curl \
     gnupg \
     autoconf \
     build-essential \
     openssl \
     librabbitmq-dev \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    docker-php-ext-configure intl; \
    docker-php-ext-install -j$(nproc) \
      pdo \
      pdo_pgsql \
      zip \
      bcmath \
      gd \
      intl \
      xsl \
      xml \
      soap \
      opcache \
      pcntl \
      sockets \
      mbstring \
    ; \
    pecl install redis amqp; \
    docker-php-ext-enable redis amqp

COPY --from=roadrunner /usr/bin/rr /usr/local/bin/rr
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
COPY php.ini /usr/local/etc/php/php.ini
COPY start.sh /usr/local/bin/start.sh
COPY worker-start.sh /usr/local/bin/worker-start.sh
COPY wait-for-tcp.sh /usr/local/bin/wait-for-tcp.sh

RUN set -eux; \
    chmod +x /usr/local/bin/start.sh /usr/local/bin/worker-start.sh /usr/local/bin/wait-for-tcp.sh; \
    groupadd -g ${APP_GID} ${CONTAINER_USER}; \
    useradd -m -u ${APP_UID} -g ${APP_GID} -s /bin/sh ${CONTAINER_USER}

WORKDIR /var/www/api

EXPOSE 8080

FROM base AS prod

USER ${CONTAINER_USER}

FROM base AS dev

ARG APP_UID=1000
ARG APP_GID=1000
ARG CONTAINER_USER=app

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
     mc \
     nano \
     net-tools \
     procps \
     zsh \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    pecl install xdebug; \
    docker-php-ext-enable xdebug

COPY conf.d/99-xdebug.ini /usr/local/etc/php/conf.d/99-xdebug.ini

RUN set -eux; \
    wget https://get.symfony.com/cli/installer -O - | bash; \
    mv /root/.symfony*/bin/symfony /usr/local/bin/symfony; \
    chmod +x /usr/local/bin/symfony

COPY --chown=${APP_UID}:${APP_GID} .zshrc /home/${CONTAINER_USER}/.zshrc
COPY --chown=${APP_UID}:${APP_GID} aliases.sh /home/${CONTAINER_USER}/aliases.sh

RUN set -eux; \
    usermod -s /usr/bin/zsh ${CONTAINER_USER}; \
    su - ${CONTAINER_USER} -c 'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'; \
    su - ${CONTAINER_USER} -c 'git clone https://github.com/zsh-users/zsh-autosuggestions /home/'"${CONTAINER_USER}"'/.oh-my-zsh/custom/plugins/zsh-autosuggestions'; \
    su - ${CONTAINER_USER} -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/'"${CONTAINER_USER}"'/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting'; \
    su - ${CONTAINER_USER} -c 'git clone https://github.com/zsh-users/zsh-completions /home/'"${CONTAINER_USER}"'/.oh-my-zsh/custom/plugins/zsh-completions'

USER ${CONTAINER_USER}
