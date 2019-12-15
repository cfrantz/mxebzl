#!/bin/bash --norc

PROG=$(basename "$0")
DRIVER_DIR=$(dirname "$0")
MXE="mxe_compiler"
VERSION="5.5.0"
PREFIX="x86_64-w64-mingw32.shared"
export COMPILER_PATH="external/${MXE}/usr/libexec/gcc/${PREFIX}/${VERSION}:external/${MXE}/usr/bin:${DRIVER_DIR}"
export CPATH="external/${MXE}/usr/${PREFIX}/include:external/${MXE}/usr/lib/gcc/${PREFIX}/${VERSION}/include"
export CPLUS_INCLUDE_PATH="external/${MXE}/usr/lib/gcc/${PREFIX}/${VERSION}/include/c++:external/${MXE}/usr/lib/gcc/${PREFIX}/${VERSION}/include/c++/${PREFIX}"
export LIBRARY_PATH="external/${MXE}/usr/${PREFIX}/lib:external/${MXE}/usr/lib/gcc/${PREFIX}/${VERSION}"

ARGS=()
POSTARGS=()
case "${PROG}" in
    gcc)
        ARGS+=("-B" "external/${MXE}/usr/bin/${PREFIX}-")
        ARGS+=("-std=c++14")
        ARGS+=("-O2")
        ;;
    ld)
        POSTARGS+=("-lstdc++" "-lssp")
        ;;
esac

exec "external/${MXE}/usr/bin/${PREFIX}-${PROG}" \
    "${ARGS[@]}" \
    "$@"\
    "${POSTARGS[@]}"
