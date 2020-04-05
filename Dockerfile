FROM alpine

RUN apk update && apk upgrade && \
    apk add --no-cache git autoconf automake build-base linux-headers \
    libjpeg-turbo-dev libmicrohttpd-dev libzip-dev ffmpeg-dev gettext-dev \
    libmicrohttpd ffmpeg gettext libjpeg-turbo tzdata && \
    git clone https://github.com/Motion-Project/motion.git motion-build && \
    cd motion-build && autoreconf -fiv && \
    ./configure --prefix /motion --exec-prefix /motion && \
    make && make install && cd .. && rm -rf /motion-build && \
    apk del git autoconf automake build-base linux-headers libjpeg-turbo-dev \
    libmicrohttpd-dev libzip-dev ffmpeg-dev gettext-dev && \
    rm -rf /tmp/* /var/tmp/*

VOLUME [ "/motion/config", "/motion/data" ]

RUN if [ ! -f /motion/etc/motion/motion.conf ]; then \
    cp /motion/etc/motion/motion-dist.conf motion/etc/motion/motion.conf; fi && \
    sed -i 's/; target_dir value/target_dir \/motion\/data/' /motion/etc/motion/motion.conf && \
    sed -i 's/; log_file value/log_file \/motion\/log\/motion.log/' /motion/etc/motion/motion.conf && \
    sed -i 's/; pid_file value/pid_file \/run\/motion.pid/' /motion/etc/motion/motion.conf && \
    mv /motion/etc/motion /motion/etc/motion-dist && \
    mkdir -p /motion/log

COPY motion-run /usr/local/bin/

CMD [ "motion-run" ]
