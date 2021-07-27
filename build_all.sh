#!/usr/bin/env bash

# simply loop to build all supported versions

BUILD_IMAGE="${BUILD_IMAGE-${workdir}/build.sh}"

mian()
{
    # since we are using bash, there's array!
    local SUPPORTED_ALPINE=(edge 3.14 3.13 3.12 3.11 3.10)
    local SUPPORTED_PHP=(8.0 7.4 7.3)

    local workdir
    workdir="$(basedir "${BASH_SOURCE[0]}")"
    for alpinever in "${SUPPORTED_ALPINE[@]}"
    do
        for phpver in "${SUPPORTED_PHP[@]}"
        do
            $BUILD_IMAGE alpine/base "ALPINE_VERSION=${alpinever##v}" "PHP_VERSION=${phpver}"
        done
    done
}

mian "$@"
