#!/bin/bash -ex
PREFIX="$(pwd)/build"
mkdir source
wget -qO- https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz | tar -xJ -C source --strip-components=1
cd source
./configure --target=powerpc-eabi --prefix="$PREFIX" --disable-nls --disable-shared --disable-gprof --without-zstd
make -j$(nproc) configure-host
make -j$(nproc)
make install-strip
