# hyperf-docker v2

## Supported tags and respective Dockerfile links

tag format:

like `hyperf/hyperf:7.4-alpine-3.11-swoole-v4.5.5`

- 7.4: php version, support 7.3/7.4/8.0, Recommend 7.4
- alpine: base images, supoort alpine, recommend alpine
- 3.11: alpine version, support alpine 3.10/3.11/3.12, recommend 3.12
- swoole: support base/dev/swoole/swow
- v4.5.5: swoole/swow version (git revision)

**TODO**: ubuntu support

### Base images

- {7.3,7.4,8.0}-alpine-{3.10,3.11,3.12,3.13,3.14,edge}-base
- {7.3,7.4,8.0}-alpine-{v3.10,v3.11,v3.12,v3.13,v3.14}-base (for backward compatiable)

[alpine/base/Dockerfile](alpine/base/Dockerfile)

### Swoole images (multi-staged)

- {versions}-alpine-{versions}-swoole-{versions}-builder

[alpine/swoole/Dockerfile.builder](alpine/swoole/Dockerfile.builder)

- {versions}-alpine-{versions}-swoole-{versions}

[alpine/swoole/Dockerfile](alpine/swoole/Dockerfile)

- {versions}-alpine-{versions}-swoole-{versions}-debuggable

[alpine/swoole/Dockerfile.debugable](alpine/swoole/Dockerfile.debugable)

### Swow images (multi-staged)

- {versions}-alpine-{versions}-swow-{versions}-builder

[alpine/swow/Dockerfile.builder](alpine/swow/Dockerfile.builder)

- {versions}-alpine-{versions}-swow-{versions}

[alpine/swow/Dockerfile](alpine/swow/Dockerfile)

- {versions}-alpine-{versions}-swow-{versions}-debuggable

[alpine/swow/Dockerfile.debugable](alpine/swow/Dockerfile.debugable)

## Debuggable images

For Swoole or Swow images, there are "debuggable" varients images, it keeps Swo* sources ( at /usr/src/{swow,swoole} ) and debug symbols in its image.

It will bigger than non-debuggable varients (about +50M typically).

To use it with gdb:

```bash
apk update
# asumming you are using 7.3
apk add gdb php7-dbg~7.3
# or 8.0
apk add gdb php8-dbg~8.0
# you may need fetch php sources by yourself if you want to debug php also.
# then you can debug things with gdb:
gdb --args php -r 'echo "hello";'
gdb attach $(pgrep -o somephp)
```

## Quick reference

- [hyperf](https://github.com/hyperf)
- [hyperf doc](https://doc.hyperf.io)

## How to use this image

Added [Dockerfile](Dockerfile) to your project.

## Info

Base image contains extensions below:

```plain
[PHP Modules]
bcmath
Core
ctype
curl
date
dom
filter
gd
hash
iconv
igbinary
json
libxml
mbstring
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
readline
redis
Reflection
session
SimpleXML
sockets
sodium
SPL
standard
sysvmsg
sysvsem
sysvshm
tokenizer
xml
xmlreader
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```

## more demo

**TODO**: update this part

### kafka

```dockerfile
RUN apk add --no-cache librdkafka-dev \
&& pecl install rdkafka \
&& echo "extension=rdkafka.so" > /etc/php7/conf.d/rdkafka.ini
```

### aerospike

```dockerfile
# aerospike @see https://github.com/aerospike/aerospike-client-php/issues/24
RUN git clone https://gitlab.innotechx.com/liyibocheng/aerospike-c-client.git /tmp/aerospike-client-c \
&& ( \
    cd /tmp/aerospike-client-c \
    && make \
) \
&& export PREFIX=/tmp/aerospike-client-c/target/Linux-x86_64 \
&& export DOWNLOAD_C_CLIENT=0 \
&& git clone https://gitlab.innotechx.com/liyibocheng/aerospike-client-php.git /tmp/aerospike-client-php \
&& ( \
    cd /tmp/aerospike-client-php/src \
    && ./build.sh \
    && make install \
    && echo "extension=aerospike.so" > /etc/php7/conf.d/aerospike.ini \
    && echo "aerospike.udf.lua_user_path=/usr/local/aerospike/usr-lua" >> /etc/php7/conf.d/aerospike.ini \
)
```

### mongodb

```dockerfile
RUN apk add --no-cache openssl-dev \
&& pecl install mongodb \
&& echo "extension=mongodb.so" > /etc/php7/conf.d/mongodb.ini
```

### protobuf

```dockerfile
# mac protobuf: https://blog.csdn.net/JoeBlackzqq/article/details/83118248
RUN apk add --no-cache protobuf \
&& cd /tmp \
&& pecl install protobuf \
&& echo "extension=protobuf.so" > /etc/php7/conf.d/protobuf.ini
```

### swoole tracker

```dockerfile
# download swoole tracker
ADD ./swoole-tracker-install.sh /tmp

RUN chmod +x /tmp/swoole-tracker-install.sh \
&& cd /tmp \
&& ./swoole-tracker-install.sh \
&& rm /tmp/swoole-tracker-install.sh \
# config
&& cp /tmp/swoole-tracker/swoole_tracker72.so /usr/lib/php7/modules/swoole_tracker72.so \
&& echo "extension=swoole_tracker72.so" > /etc/php7/conf.d/swoole-tracker.ini \
&& echo "apm.enable=1" >> /etc/php7/conf.d/swoole-tracker.ini \
&& echo "apm.sampling_rate=100" >> /etc/php7/conf.d/swoole-tracker.ini \
&& echo "apm.enable_memcheck=1" >> /etc/php7/conf.d/swoole-tracker.ini \
# launch
&& printf '#!/bin/sh\n/opt/swoole/script/php/swoole_php /opt/swoole/node-agent/src/node.php' > /opt/swoole/entrypoint.sh \
&& chmod 755 /opt/swoole/entrypoint.sh
```

NOTE: swoole-tracker may need container have proper capabilities and secure options to work well, consult user manual for detail

### fix aliyun oss wrong charset

```dockerfile
# fix aliyun oss wrong charset: https://github.com/aliyun/aliyun-oss-php-sdk/issues/101
# https://github.com/docker-library/php/issues/240#issuecomment-762438977

RUN apk --no-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ add gnu-libiconv=1.15-r2
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so
```
