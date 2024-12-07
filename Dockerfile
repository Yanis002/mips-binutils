# Build stage
ARG ALPINE_VERSION=3.19.1
FROM alpine:${ALPINE_VERSION} AS build

# Install dependencies
RUN apk add --no-cache build-base musl-dev

# Install zig
ARG ZIG_VERSION=0.11.0
RUN mkdir /zig && \
    wget -qO- "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-`uname -m`-${ZIG_VERSION}.tar.xz" | \
    tar -xJ -C /zig --strip-components=1
ENV PATH="/zig:$PATH"

# Download gcc
ARG GCC_VERSION=14.2.0
RUN wget -q https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz

ARG MULTILIB

# Build host gcc
ARG GNU_TRIPLE
RUN mkdir /gcc-host && \
    tar -xf /gcc-${GCC_VERSION}.tar.xz -C /gcc-host --strip-components=1 && \
    cd /gcc-host && \
    ./contrib/download_prerequisites && \
    ./configure --target=${GNU_TRIPLE} --prefix=/usr/local ${MULTILIB} \
    --disable-nls --disable-shared --disable-gprofng --disable-ld --disable-gold && \
    make -j$(nproc) && \
    make install-strip

# Build target gcc
ARG ZIG_TRIPLE
COPY *.patch /
RUN mkdir /gcc && \
    tar -xf /gcc-${GCC_VERSION}.tar.xz -C /gcc --strip-components=1 && \
    cd /gcc && \
    # uncomment if .patch files are used
    # for patch in ../*.patch; do patch -N -p1 -i $patch; done && \
    ./contrib/download_prerequisites && \
    CC="zig cc -target ${ZIG_TRIPLE}" \
    ./configure --host=${GNU_TRIPLE} --target=mips-linux-gnu --prefix=/target ${MULTILIB} \
    --disable-nls --disable-shared --disable-gprof --without-zstd && \
    make -j$(nproc) && \
    make install-strip

# Export binary (usage: docker build --target export --output build .)
FROM scratch AS export
COPY --from=build /target .
