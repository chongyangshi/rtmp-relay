ARG ALPINE_VERSION=3.11
ARG NGINX_RTMP_MODULE_VERSION=1.2.1
FROM alpine:$ALPINE_VERSION

RUN apk --update add pcre libbz2 ca-certificates libressl ffmpeg && rm /var/cache/apk/*

RUN adduser -h /etc/nginx -D -s /bin/sh nginx
WORKDIR /tmp

ENV NGINX_VERSION=1.17.7

# add compilation env, build required C based gems and cleanup
RUN apk --update add --virtual build_deps build-base zlib-dev pcre-dev libressl-dev \
    && wget -O /tmp/nginx-rtmp-module.tar.gz https://github.com/arut/nginx-rtmp-module/archive/v1.2.1.tar.gz \
    && mkdir -p /tmp/nginx-rtmp-module \
    && tar xzf /tmp/nginx-rtmp-module.tar.gz -C /tmp/nginx-rtmp-module \
    && wget -O - https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar xzf - \
    && cd nginx-$NGINX_VERSION && ./configure \
       --prefix=/usr/share/nginx \
       --sbin-path=/usr/sbin/nginx \
       --conf-path=/etc/nginx/nginx.conf \
       --error-log-path=stderr \
       --http-log-path=/dev/stdout \
       --pid-path=/var/run/nginx.pid \
       --lock-path=/var/run/nginx.lock \
       --http-client-body-temp-path=/var/cache/nginx/client_temp \
       --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
       --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
       --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
       --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
       --user=nginx \
       --group=nginx \
       --with-http_addition_module \
       --with-http_auth_request_module \
       --with-http_gunzip_module \
       --with-http_gzip_static_module \
       --with-http_realip_module \
       --with-http_ssl_module \
       --with-http_stub_status_module \
       --with-http_sub_module \
       --with-http_v2_module \
       --with-threads \
       --with-stream \
       --with-stream_ssl_module \
       --without-http_memcached_module \
       --without-mail_pop3_module \
       --without-mail_imap_module \
       --without-mail_smtp_module \
       --with-pcre-jit \
       --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security' \
       --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
       --add-module=/tmp/nginx-rtmp-module/nginx-rtmp-module-$NGINX_RTMP_MODULE_VERSION \
    && make install \
    && cd .. && rm -rf nginx-$NGINX_VERSION \
    && mkdir /var/cache/nginx \
    && rm /etc/nginx/*.default \
    $$ mkdir -p /etc/nginx/stat \
    && apk del build_deps && rm /var/cache/apk/*

COPY stat.xsl /etc/nginx/stat/
COPY nginx.conf /etc/nginx/
COPY init.sh /
RUN chmod +x /init.sh
ADD conf.d /etc/nginx/conf.d

VOLUME ["/var/cache/nginx"]
EXPOSE 80

CMD ["sh", "/init.sh"]