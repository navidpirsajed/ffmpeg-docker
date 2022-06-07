FROM debian

EXPOSE 3000
EXPOSE 80

RUN    apt update
RUN    apt upgrade -y
RUN    apt -y install nodejs npm autoconf automake build-essential cmake doxygen git graphviz imagemagick libasound2-dev libass-dev libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libfreetype6-dev libgmp-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev librtmp-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev libsnappy-dev libsoxr-dev libssh-dev libssl-dev libtool libv4l-dev libva-dev libvdpau-dev libvo-amrwbenc-dev libvorbis-dev libwebp-dev libx264-dev libx265-dev libxcb-shape0-dev libxcb-shm0-dev libxcb-xfixes0-dev libxcb1-dev libxml2-dev lzma-dev meson nasm pkg-config python3-dev python3-pip texinfo wget yasm zlib1g-dev libdrm-dev

RUN    mkdir ~/ffmpeg-libraries

RUN    git clone --depth 1 https://github.com/navidpirsajed/fdk-aac ~/ffmpeg-libraries/fdk-aac 
RUN    git clone --depth 1 https://github.com/navidpirsajed/kvazaar ~/ffmpeg-libraries/kvazaar 
RUN    git clone --depth 1 https://chromium.googlesource.com/webm/libvpx ~/ffmpeg-libraries/libvpx 
RUN    git clone -b release-3.0.4 https://github.com/navidpirsajed/zimg ~/ffmpeg-libraries/zimg 
RUN    git clone --depth 1 https://aomedia.googlesource.com/aom ~/ffmpeg-libraries/aom 
RUN    git clone --branch release/5.0 --depth 1 https://github.com/navidpirsajed/FFmpeg ~/FFmpeg

RUN  cd ~/ffmpeg-libraries/fdk-aac \
  && autoreconf -fiv \
  && ./configure \
  && make -j$(nproc) \
  && make install

RUN  cd ~/ffmpeg-libraries/kvazaar \
  && ./autogen.sh \
  && ./configure \
  && make -j$(nproc) \
  && make install

RUN  cd ~/ffmpeg-libraries/libvpx \
  && ./configure --disable-examples --disable-tools --disable-unit_tests --disable-docs \
  && make -j$(nproc) \
  && make install

RUN  cd ~/ffmpeg-libraries/zimg \
  && sh autogen.sh \
  && ./configure \
  && make \
  && make install

RUN  mkdir ~/ffmpeg-libraries/aom/aom_build \
  && cd ~/ffmpeg-libraries/aom/aom_build \
  && cmake -G "Unix Makefiles" AOM_SRC -DENABLE_NASM=on -DPYTHON_EXECUTABLE="$(which python3)" .. \
  && make -j$(nproc) \
  && sudo make install

RUN    ldconfig

RUN  cd ~/FFmpeg \
  && ./configure \
    --extra-cflags="-I/usr/local/include" \
    --extra-ldflags="-L/usr/local/lib" \
    --extra-libs="-lpthread -lm -latomic" \
    --arch=armel   \
    --enable-gmp \
    --enable-gpl \
    --enable-libaom \
    --enable-libass \
    --enable-libdrm \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libkvazaar \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsnappy \
    --enable-libsoxr \
    --enable-libssh \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libzimg \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxml2 \
    --enable-nonfree \
    --enable-version3 \
    --target-os=linux \
    --enable-pthreads \
    --enable-openssl \
    --enable-hardcoded-tables \
    --enable-mmal \
  && make -j$(nproc) \
  && make install

ENTRYPOINT [ "/entrypoint.sh" ]

