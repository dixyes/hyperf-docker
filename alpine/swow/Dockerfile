# hyperf/hyperf swow image
#
# @link     https://www.hyperf.io
# @document https://doc.hyperf.io
# @contact  group@hyperf.io
# @license  https://github.com/hyperf/hyperf/blob/master/LICENSE

ARG IMAGE_NAME
ARG ALPINE_VERSION
ARG PHP_VERSION
ARG SWOW_VERSION

FROM ${IMAGE_NAME}:${PHP_VERSION}-alpine-${ALPINE_VERSION}-swow-${SWOW_VERSION}-builder as builder

FROM ${IMAGE_NAME}:${PHP_VERSION}-alpine-${ALPINE_VERSION}-base

LABEL maintainer="Hyperf Developers <group@hyperf.io>" version="2.0" license="MIT"

ARG ALPINE_VERSION
ARG PHP_VERSION
ARG SWOW_VERSION
ARG COMPOSER_VERSION

# install swow
COPY --from=builder /tmp/stripped /

RUN set -eo pipefail ; \
    suffix=${PHP_VERSION%%.*}; \
    # runtime libraries
    apk add --no-cache \
        libstdc++ \
        zlib \
        openssl \
    && \
    # generate configure
    echo "memory_limit=1G" > /etc/php${suffix}/conf.d/00_default.ini && \
    echo "opcache.enable_cli = 'On'" >> /etc/php${suffix}/conf.d/00_opcache.ini && \
    echo "extension=swow.so" > /etc/php${suffix}/conf.d/50_swow.ini && \
    # install composer
    if [ "x$COMPOSER_VERSION" = "x" ] ; then \
        curl -fSL 'https://getcomposer.org/download/latest-stable/composer.phar' -o /usr/local/bin/composer; \
    else \
        curl -fSL 'https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar' -o /usr/local/bin/composer; \
    fi && \
    chmod 0755 /usr/local/bin/composer && \
    # validate extensions loading
    { [ x$(php -r 'var_dump(class_exists("\Swow\Coroutine"));' 2>&1) = "xbool(true)" ] || exit 1; } && \
    # php info
    printf "\033[42;37m PHP version is \033[0m\n" && \
    php -v && \
    printf "\033[42;37m PHP modules are \033[0m\n" && \
    php -m && \
    printf "\033[42;37m Used Swow is \033[0m\n" && \
    php --ri swow && \
    printf "\033[42;37m Used Composer is \033[0m\n" && \
    composer -V && \
    printf "\033[42;37m Build Completed :).\033[0m\n"
