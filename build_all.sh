#!/usr/bin/env bash

# simply loop to build all supported versions

mian()
{
    local target="$1"
    # since we are using bash, there's array!
    # also, these arrays is used for actions to generate tasks
    local SUPPORTED_ALPINE=(edge 3.14 3.13 3.12 3.11 3.10)
    #local SUPPORTED_ALPINE=(3.12)
    local SUPPORTED_PHP=(8.0 7.4 7.3)
    local SUPPORTED_SWOOLE=(master v4.7.0)
    local SUPPORTED_SWOW=(develop v0.1.0-nightly20210601)
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
                    if [ "${SWOOLE_VERSION}" = "" ]
                    then
                        local swver; for swver in "${SUPPORTED_SWOOLE[@]}"
                        do
                            $BUILD_IMAGE alpine/swoole "ALPINE_VERSION=${alpinever##v}" "PHP_VERSION=${phpver}" SWOOLE_VERSION="${swver}"
                        done
                    else
                        $BUILD_IMAGE alpine/swoole "ALPINE_VERSION=${alpinever##v}" "PHP_VERSION=${phpver}" SWOOLE_VERSION="${SWOOLE_VERSION}"
                    fi ;;
                "swow")
                    if [ "${SWOW_VERSION}" = "" ]
                    then
                        local swver; for swver in "${SUPPORTED_SWOW[@]}"
                        do
                            $BUILD_IMAGE alpine/swoole "ALPINE_VERSION=${alpinever##v}" "PHP_VERSION=${phpver}" SWOOLE_VERSION="${swver}"
                        done
                    else
                        $BUILD_IMAGE alpine/swoole "ALPINE_VERSION=${alpinever##v}" "PHP_VERSION=${phpver}" SWOOLE_VERSION="${SWOW_VERSION}"
                    fi ;;
            esac
        done
    done
}

mian "$@"
