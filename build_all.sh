#!/usr/bin/env bash

# simply loop to build all supported versions

mian()
{
    local target="$1"
    # since we are using bash, there's array!
    local SUPPORTED_ALPINE=(edge 3.14 3.13 3.12 3.11 3.10)
    #local SUPPORTED_ALPINE=(3.12)
    local SUPPORTED_PHP=(8.0 7.4 7.3)
    #local SUPPORTED_PHP=(7.4)

    local workdir
    workdir="$(dirname "${BASH_SOURCE[0]}")"
    local BUILD_IMAGE="${BUILD_IMAGE-${workdir}/build.sh}"

    local alpinever; for alpinever in "${SUPPORTED_ALPINE[@]}"
    do
        local phpver; for phpver in "${SUPPORTED_PHP[@]}"
        do
            case $target in
                *) ;&
                "base")
                    $BUILD_IMAGE alpine/base "ALPINE_VERSION=${alpinever##v}" "PHP_VERSION=${phpver}" ;;
                "swoole")
                    $BUILD_IMAGE alpine/swoole "ALPINE_VERSION=${alpinever##v}" "PHP_VERSION=${phpver}" SWOOLE_VERSION="${SWOOLE_VERSION-v4.7.0}" ;;
                "swow")
                    $BUILD_IMAGE alpine/swow "ALPINE_VERSION=${alpinever##v}" "PHP_VERSION=${phpver}" SWOW_VERSION="${SWOW_VERSION-v0.1.0-nightly20210601}" ;;
            esac
        done
    done
}

mian "$@"
