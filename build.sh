#!/usr/bin/env bash

# build image with docker build command, needs bash, coreutils

set -eo pipefail

sh_source="${BASH_SOURCE[0]}"
sh_source="${sh_source-$0}"
script_dir=$(dirname "${sh_source}")

IMAGE_NAME=${IMAGE_NAME-hyperf/hyperf}

usage()
{
    cat <<EOF
build docker image
Usage: ${1} <path> [arguments]
where
    path: the dir path to build, like alpine/base;
    arguments: environments to use, different dir may support vary
Environments:
    IMAGE_NAME: build image name, default is hyperf/hyperf, its ${IMAGE_NAME} now
EOF
}

buildbase()
{
    local target="$1"
    local os_version
    local php_version
    local os_name=${target%%/*}
    shift
    local merged_args=()
    local arg; for arg in "$@"
    do
        merged_args+=("--build-arg" "$arg")
        local k=${arg%%=*}
        local v=${arg#*=}
        [ "$k" = "ALPINE_VERSION" ] && os_version="$v"
        [ "$k" = "UBUNTU_VERSION" ] && os_version="$v"
        [ "$k" = "PHP_VERSION" ] && php_version="$v"
    done
    # OS_VERSION and PHP_VERSION must be set and not empty
    : ${os_version:?ALPINE_VERSION or UBUNTU_VERSION must be set}
    : ${php_version:?PHP_VERSION must be set}

    docker build "$script_dir/$target" \
        -t "${IMAGE_NAME}:${php_version}-${os_name}-${os_version}-base" \
        "${merged_args[@]}"
    # TODO: alias it
}

buildext()
{
    local target="$1"
    local os_version
    local php_version
    local ext_version
    local os_name=${target%%/*}
    local ext_name=${target##*/}
    shift
    local merged_args=()
    local arg; for arg in "$@"
    do
        merged_args+=("--build-arg" "$arg")
        local k=${arg%%=*}
        local v=${arg#*=}
        [ "$k" = "ALPINE_VERSION" ] && os_version="$v"
        [ "$k" = "UBUNTU_VERSION" ] && os_version="$v"
        [ "$k" = "PHP_VERSION" ] && php_version="$v"
        [ "$k" = "SWOOLE_VERSION" ] && ext_version="$v"
        [ "$k" = "SWOW_VERSION" ] && ext_version="$v"
    done
    # OS_VERSION and PHP_VERSION must be set and not empty
    : ${os_version:?ALPINE_VERSION or UBUNTU_VERSION must be set}
    : ${php_version:?PHP_VERSION must be set}

    docker build "$script_dir/$target" \
        -f "$script_dir/$target/Dockerfile.builder" \
        -t "${IMAGE_NAME}:${php_version}-${os_name}-${os_version}-${ext_name}-${ext_version}-builder" \
        "${merged_args[@]}"
    docker build "$script_dir/$target" \
        -t "${IMAGE_NAME}:${php_version}-${os_name}-${os_version}-${ext_name}-${ext_version}" \
        "${merged_args[@]}"
    # TODO: alias it
    docker build "$script_dir/$target" \
        -f "$script_dir/$target/Dockerfile.debuggable" \
        -t "${IMAGE_NAME}:${php_version}-${os_name}-${os_version}-${ext_name}-${ext_version}-debuggable" \
        "${merged_args[@]}"
    # TODO: alias it
}

build()
{
    local bin_name=${1%%/}
    shift
    case "$1" in
        */base) buildbase "$@";;
        */swoole|*/swow) buildext "$@";;
        *) usage "$bin_name"; exit 1 ;;
    esac
}

build "$0" "$@"
