#!/bin/bash -ex
PREFIX="$(pwd)/build"
mkdir source
wget -qO- https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz | tar -xJ -C source --strip-components=1
cd source
# uncomment if .patch files are used
# for patch in ../*.patch; do
#   patch -N -p1 -i "$patch"
# done
./contrib/download_prerequisites
./configure --target=mips-linux-gnu --prefix="$PREFIX" --disable-nls --disable-shared --disable-gprof --without-zstd --disable-multilib
make -j$(nproc) configure-host
make -j$(nproc)
make install-strip
