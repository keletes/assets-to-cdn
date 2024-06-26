FROM alpine:latest AS fswatch
RUN apk add --no-cache autoconf alpine-sdk
RUN rm /usr/include/sys/inotify.h
RUN wget https://github.com/emcrisostomo/fswatch/releases/download/1.17.1/fswatch-1.17.1.tar.gz \
&& tar -xzvf fswatch-1.17.1.tar.gz && cd fswatch-1.17.1 && ./configure && make && make install && rm -rf /fswatch-1.17.1

FROM alpine:latest
# Install needed packages
RUN apk add --no-cache s3cmd
# Copy FSWatch from build image
COPY --from=fswatch /usr/local/bin/fswatch /usr/local/bin/fswatch
COPY --from=fswatch /usr/local/lib/libfswatch.so* /usr/local/lib/

# Copying running script
COPY ./scripts .

CMD ["sh", "entrypoint.sh"]
