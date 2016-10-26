FROM minimum2scp/baseimage-jessie:latest

MAINTAINER YAMADA Tsuyoshi <tyamada@minimum2scp.org>

ARG NGINX_VERSION=1.11.5
ARG NGX_MRUBY_VERSION=v1.18.7
ARG DEB_BASE_REVISION=1~jessie
ARG DEB_NGINX_MODULE_MRUBY_VERSION=${NGINX_VERSION}-${NGX_MRUBY_VERSION}~jessie+local1

RUN sed -i -e 's/httpredir.debian.org/ftp.jp.debian.org/' /etc/apt/sources.list
RUN curl http://nginx.org/keys/nginx_signing.key | apt-key add -
RUN echo "deb     http://nginx.org/packages/mainline/debian/ jessie nginx"  > /etc/apt/sources.list.d/nginx.list
RUN echo "deb-src http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list.d/nginx.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends fakeroot devscripts git patch ruby rake bison
RUN apt-get build-dep -y nginx=${NGINX_VERSION}-${DEB_BASE_REVISION}

USER debian
RUN mkdir /home/debian/build

WORKDIR /home/debian/build
ADD http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz /home/debian/build/
RUN sudo chown debian:debian /home/debian/build/nginx-${NGINX_VERSION}.tar.gz
RUN mv nginx-${NGINX_VERSION}.tar.gz nginx-module-mruby_${NGINX_VERSION}.orig.tar.gz
RUN tar xf nginx-module-mruby_${NGINX_VERSION}.orig.tar.gz

WORKDIR /home/debian/build/nginx-${NGINX_VERSION}

ADD debian/ debian/

RUN sudo chown -R debian:debian debian

RUN git clone https://github.com/matsumoto-r/ngx_mruby.git debian/extra/ngx_mruby/
RUN cd debian/extra/ngx_mruby && git checkout ${NGX_MRUBY_VERSION}

RUN debchange --create --package nginx-module-mruby -v ${DEB_NGINX_MODULE_MRUBY_VERSION} "Initial release"
RUN debchange --append "nginx ${NGINX_VERSION}, ngx_mruby ${NGX_MRUBY_VERSION}"
RUN debchange -D stable -r ""

RUN debuild -rfakeroot -uc -us

USER root
WORKDIR /home/debian/build
RUN apt-get install -y --no-install-recommends nginx
RUN dpkg -i nginx-module-mruby_${DEB_NGINX_MODULE_MRUBY_VERSION}_amd64.deb
RUN apt-get install -f -y --no-install-recommends

ADD nginx-conf.diff /tmp/nginx-conf.diff
RUN cd /etc; patch -p1 < /tmp/nginx-conf.diff && rm /tmp/nginx-conf.diff
RUN /usr/sbin/nginx -t

WORKDIR /
EXPOSE 22 80
ENTRYPOINT ["/opt/init-wrapper/sbin/entrypoint.sh"]
CMD ["/sbin/init"]

