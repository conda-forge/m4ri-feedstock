#!/bin/bash

chmod +x configure

case `uname` in
    Darwin|Linux)
        export CFLAGS="-O3 -g -fPIC $CFLAGS"
        autoreconf --install
        chmod +x configure
        ./configure --prefix="$PREFIX" --libdir="$PREFIX"/lib --disable-sse2
        ;;
    MINGW*)
        export PATH="$PREFIX/Library/bin:$BUILD_PREFIX/Library/bin:$PATH"
        export CC=clang-cl
        export RANLIB=llvm-ranlib
        export AS=llvm-as
        export AR=llvm-ar
        export LD=lld-link
        export CFLAGS="-MD -I$PREFIX/Library/include -O3 -Dsrandom=srand -Drandom=rand"
        export LDFLAGS="$LDFLAGS -L$PREFIX/Library/lib"
        sed -i "s/-Wl,-DLL,-IMPLIB/-link -DLL -IMPLIB/g" configure
        sed -i "s/#include <unistd.h>//g" m4ri/djb.c
        ./configure --prefix="$PREFIX/Library" --libdir="$PREFIX/Library/lib" --disable-sse2
        ;;
esac

make -j${CPU_COUNT}
make check -j${CPU_COUNT}
make install

PROJECT=m4ri
if [[ `uname` == MINGW* ]]; then
    LIBRARY_LIB=$PREFIX/Library/lib
    mv "${LIBRARY_LIB}/${PROJECT}.lib" "${LIBRARY_LIB}/${PROJECT}_static.lib"
    mv "${LIBRARY_LIB}/${PROJECT}.dll.lib" "${LIBRARY_LIB}/${PROJECT}.lib"
fi

