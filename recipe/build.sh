#!/bin/bash

set -e

autoreconf -vfi
chmod +x configure

case $target_platform in
    osx-*|linux-*)
        export CFLAGS="-O3 -g -fPIC $CFLAGS"
        ;;
    win-*)
        export CFLAGS="-MD -I$PREFIX/include -O2 -DM4RI_USE_DLL"
        export lt_cv_deplibs_check_method=pass_all
        export ac_cv_prog_cc_c11=""
        export ac_cv_prog_cc_c99=""
        ;;
esac

configure_args="--prefix=$PREFIX --libdir=$PREFIX/lib --disable-sse2 --disable-static"

if [[ "$target_platform" == "win-64" ]]; then
    # configure.ac sets -Wl,--export-all-symbols for mingw, but libtool strips
    # the -Wl, prefix and passes --export-all-symbols directly to clang which
    # rejects it. Symbol exports are handled via .def files already.
    configure_args="$configure_args M4RI_EXPORT_ALL_SYMBOLS_LDFLAGS="
fi

./configure $configure_args

[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  make check -j${CPU_COUNT}
fi
make install
