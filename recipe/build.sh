#!/bin/bash

set -e

autoreconf -vfi
chmod +x configure

case $target_platform in
    osx-*|linux-*)
        export CFLAGS="-O3 -g -fPIC $CFLAGS"
        ./configure --prefix="$PREFIX" --libdir="$PREFIX"/lib --disable-sse2
        ;;
    win-*)
        export CFLAGS="-MD -I$PREFIX/Library/include -O2 -DM4RI_USE_DLL"
        export LDFLAGS="$LDFLAGS -L$PREFIX/Library/lib"
        export lt_cv_deplibs_check_method=pass_all
        ./configure --prefix="$PREFIX/Library" --libdir="$PREFIX/Library/lib" --disable-sse2
        ;;
esac

[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make check -j${CPU_COUNT}
fi
make install

PROJECT=m4ri
if [[ "$target_platform" == win-* ]]; then
    LIBRARY_LIB=$PREFIX/Library/lib
    mv "${LIBRARY_LIB}/${PROJECT}.lib" "${LIBRARY_LIB}/${PROJECT}_static.lib"
    mv "${LIBRARY_LIB}/${PROJECT}.dll.lib" "${LIBRARY_LIB}/${PROJECT}.lib"
fi

