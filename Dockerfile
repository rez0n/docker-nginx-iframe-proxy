FROM debian:stretch-slim

ENV NGINX_VERSION 1.13.6
ENV NGX_DEVEL_KIT_VERSION 0.3.0
ENV SET_MISC_NGINX_MODULE_VERSION 0.32
ENV HEADERS_MORE_NGINX_MODULE_VERSION 0.33

RUN CONFIG="\
   --with-ld-opt='-Wl,-rpath,/usr/local/lib' \
   --prefix=/etc/nginx \
   --sbin-path=/usr/sbin/nginx \
   --modules-path=/usr/lib/nginx/modules \
   --conf-path=/etc/nginx/nginx.conf \
   --error-log-path=/var/log/nginx/error.log \
   --http-log-path=/var/log/nginx/access.log \
   --pid-path=/var/run/nginx.pid \
   --lock-path=/var/run/nginx.lock \
   --http-client-body-temp-path=/var/lib/nginx/body \
   --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
   --http-proxy-temp-path=/var/lib/nginx/proxy \
   --http-scgi-temp-path=/var/lib/nginx/scgi \
   --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
   --user=www-data \
   --group=www-data \
   --with-debug \
   --with-http_ssl_module \
   --with-threads \
   --with-compat \
   --with-file-aio \
   --with-http_v2_module \
   --with-http_realip_module \
   --with-http_sub_module \
   --add-module=/usr/local/nginx/modules/ngx_devel_kit \
   --add-module=/usr/local/nginx/modules/set_misc_nginx_module \
   --add-module=/usr/local/nginx/modules/headers_more_nginx_module \
   " \
   # install dependencies
   && apt-get update \
   && apt-get install -y curl gcc libpcre3-dev zlib1g-dev make libssl-dev libxslt1-dev libgd-dev libgeoip-dev \

   # download ngx_devel_kit
   && curl -fSL https://github.com/simplresty/ngx_devel_kit/archive/v$NGX_DEVEL_KIT_VERSION.tar.gz -o ngx_devel_kit.tar.gz \
   && mkdir -p /usr/local/nginx/modules/ngx_devel_kit \
   && tar -zxC /usr/local/nginx/modules/ngx_devel_kit  --strip-components=1 -f ngx_devel_kit.tar.gz \
   && rm ngx_devel_kit.tar.gz \

   # download set-misc-nginx-module
   && curl -fSL https://github.com/openresty/set-misc-nginx-module/archive/v$SET_MISC_NGINX_MODULE_VERSION.tar.gz -o set_misc_nginx_module.tar.gz \
   && mkdir -p /usr/local/nginx/modules/set_misc_nginx_module \
   && tar -zxC /usr/local/nginx/modules/set_misc_nginx_module --strip-components=1 -f set_misc_nginx_module.tar.gz \
   && rm set_misc_nginx_module.tar.gz \
   
   # download set-misc-nginx-module
   && curl -fSL https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_NGINX_MODULE_VERSION.tar.gz -o headers_more_nginx_module.tar.gz \
   && mkdir -p /usr/local/nginx/modules/headers_more_nginx_module \
   && tar -zxC /usr/local/nginx/modules/headers_more_nginx_module --strip-components=1 -f headers_more_nginx_module.tar.gz \
   && rm headers_more_nginx_module.tar.gz \

   # install nginx
   && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
   && tar -zxC /usr/src -f nginx.tar.gz \
   && rm nginx.tar.gz \
   && cd /usr/src/nginx-$NGINX_VERSION \
   && ./configure $CONFIG \
   && make -j$(getconf _NPROCESSORS_ONLN) \
   && make install \
   && mkdir -p /var/log/nginx/ \

   # create necessary directories and files
   && ln -sf /dev/stdout /var/log/nginx/access.log \
   && ln -sf /dev/stderr /var/log/nginx/error.log \
   && mkdir -p /var/lib/nginx \
   && mkdir -p /etc/nginx/sites-enabled \
   && mkdir -p /etc/nginx/modules-enabled \
   && mkdir -p /etc/nginx/conf.d

ADD nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]