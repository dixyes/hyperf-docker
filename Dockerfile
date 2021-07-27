# Default Dockerfile
#
# @link     https://www.hyperf.io
# @document https://doc.hyperf.io
# @contact  group@hyperf.io
# @license  https://github.com/hyperf-cloud/hyperf/blob/master/LICENSE

FROM hyperf/hyperf:7.4-alpine-3.11-swoole
LABEL maintainer="Hyperf Developers <group@hyperf.io>" version="1.0" license="MIT"

##
# ---------- env settings ----------
##
# --build-arg timezone=Asia/Shanghai
ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
    APP_ENV=prod

# update
RUN set -eo pipefail; \
    #  ---------- some config ----------
    # - config PHP
    { \
        echo "upload_max_filesize=100M"; \
        echo "post_max_size=108M"; \
        echo "memory_limit=1024M"; \
        echo "date.timezone=${TIMEZONE}"; \
    } | tee /etc/php$(php -r "echo PHP_MAJOR_VERSION;")/conf.d/99-overrides.ini && \
    # - config timezone
    ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    # show php version and extensions
    printf "\033[42;37m PHP version is \033[0m\n" && \
    php -v && \
    printf "\033[42;37m PHP modules are \033[0m\n" && \
    php -m && \
    printf "\033[42;37m Build Completed :).\033[0m\n"

COPY . /opt/www

WORKDIR /opt/www

RUN composer install --no-dev -o

EXPOSE 9501

ENTRYPOINT ["php", "/opt/www/bin/hyperf.php", "start"]
