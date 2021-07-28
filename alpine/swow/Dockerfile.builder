# hyperf/hyperf swow builder image
#
# @link     https://www.hyperf.io
# @document https://doc.hyperf.io
# @contact  group@hyperf.io
# @license  https://github.com/hyperf/hyperf/blob/master/LICENSE

ARG IMAGE_NAME
ARG ALPINE_VERSION
ARG PHP_VERSION

FROM ${IMAGE_NAME}:${PHP_VERSION}-alpine-${ALPINE_VERSION}-base

ARG ALPINE_VERSION
ARG PHP_VERSION
ARG SWOW_VERSION
ARG COMPOSER_VERSION

# build extension
RUN set -eo pipefail; \
    suffix=${PHP_VERSION%%.*}; \
    # build time dependencies
    apk add --no-cache --virtual .build-deps \
        # build tools
        autoconf \
        file \
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
    && \
    # download swow source
    mkdir -p /usr/src/swow && \
    cd /usr/src && \
    curl -SL "https://github.com/swow/swow/archive/${SWOW_VERSION}.tar.gz" -o swow.tar.gz && \
    tar -xf swow.tar.gz -C swow --strip-components=1 && \
    rm swow.tar.gz && \
    cd swow/ext && \
    # build swow
    phpize${suffix} && \
    ./configure \
        --with-php-config=/usr/bin/php-config${suffix} \
        --enable-swow-curl \
        --enable-swow-ssl && \
    cp -r /usr/src/swow /usr/src/swow.notbuilt && \
    make -s -j$(nproc) EXTRA_CFLAGS='-g -O2' && \
    make install INSTALL_ROOT=/tmp/stripped && \
    make install INSTALL_ROOT=/tmp/withdebug && \
    cd /tmp/stripped && \
    { find . -type f -name "*.so" -exec strip -s {} \; || : ; } &&\
    #tar czvf ../stripped.tar.gz * &&\
    #rm -rf /tmp/stripped && \
    printf "\033[42;37m Built Swow is \033[0m\n" && \
    php -dextension=/usr/src/swow/ext/.libs/swow.so --ri swow
