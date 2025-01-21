#!/bin/bash

set -e

# remove after 20240729
sed -i.bak "s/@SIMD_CFLAGS@//g" m4ri.pc.in

autoreconf -vfi
chmod +x configure

case $target_platform in
    osx-*|linux-*)
        export CFLAGS="-O3 -g -fPIC $CFLAGS"
        ;;
    win-*)
        export CFLAGS="-MD -I$PREFIX/include -O2 -DM4RI_USE_DLL"
        export lt_cv_deplibs_check_method=pass_all
        ;;
esac

./configure --prefix="$PREFIX" --libdir="$PREFIX"/lib --disable-sse2 --disable-static

[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  make check -j${CPU_COUNT}
fi
make install
