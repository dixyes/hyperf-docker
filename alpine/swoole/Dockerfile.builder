# hyperf/hyperf swoole builder image
#
# @link     https://www.hyperf.io
# @document https://doc.hyperf.io
# @contact  group@hyperf.io
# @license  https://github.com/hyperf/hyperf/blob/master/LICENSE

ARG ALPINE_VERSION
ARG PHP_VERSION

FROM hyperf/hyperf:${PHP_VERSION}-alpine-${ALPINE_VERSION}-base

ARG ALPINE_VERSION
ARG PHP_VERSION
ARG SWOOLE_VERSION
ARG COMPOSER_VERSION

# build extension
RUN set -eo pipefail; \
    suffix=${PHP_VERSION%%.*}; \
    # build time dependencies
    apk add --no-cache --virtual .build-deps \
        # libraries
        libstdc++ \
        # build tools
        autoconf \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkgconf \
        re2c \
        libtool \
        automake \
        # headers
        php${suffix}-dev~${PHP_VERSION} \
        php${suffix}-pear~${PHP_VERSION} \
        zlib-dev \
        openssl-dev \
        curl-dev \
        brotli-dev \
    && \
    # download swoole source
    mkdir -p /usr/src/swoole && \
    cd /usr/src && \
    curl -SL "https://github.com/swoole/swoole-src/archive/${SWOOLE_VERSION}.tar.gz" -o swoole.tar.gz && \
    tar -xf swoole.tar.gz -C swoole --strip-components=1 && \
    rm swoole.tar.gz && \
    cd swoole && \
    # build swoole
    phpize${suffix} && \
    ./configure \
        --with-php-config=/usr/bin/php-config${suffix} \
        --enable-openssl \
        --enable-http2 \
        --enable-swoole-curl \
        --enable-swoole-json && \
    cp -r /usr/src/swoole /usr/src/swoole.notbuilt && \
    make -s -j$(nproc) EXTRA_CFLAGS='-g -O2' && \
    make install INSTALL_ROOT=/tmp/stripped && \
    make install INSTALL_ROOT=/tmp/withdebug && \
    cd /tmp/stripped && \
    { find . -type f -name "*.so" -exec strip -s {} \; || : ; } &&\
    printf "\033[42;37m Built Swoole is \033[0m\n" && \
    php -dextension=/usr/src/swoole/.libs/swoole.so --ri swoole
