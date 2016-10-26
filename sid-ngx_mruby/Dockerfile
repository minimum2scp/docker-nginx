FROM minimum2scp/baseimage:latest

MAINTAINER YAMADA Tsuyoshi <tyamada@minimum2scp.org>

ARG NGINX_VERSION=1.11.5
ARG NJS_VERSION=0.1.3
ARG DEB_BASE_REVISION=1~jessie
ARG NGX_MRUBY_VERSION=v1.18.7
ARG DEB_NGINX_MODULE_MRUBY_VERSION=${NGINX_VERSION}-${NGX_MRUBY_VERSION}~sid+local1

RUN sed -i -e 's/httpredir.debian.org/ftp.jp.debian.org/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends gnupg
RUN curl http://nginx.org/keys/nginx_signing.key | apt-key add -
#RUN echo "deb     http://nginx.org/packages/mainline/debian/ jessie nginx"  > /etc/apt/sources.list.d/nginx.list
RUN echo "deb-src http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list.d/nginx.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends fakeroot devscripts git patch ruby rake bison
RUN apt-get build-dep -y \
  nginx=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-geoip=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-image-filter=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-perl=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-xslt=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-${DEB_BASE_REVISION}

USER debian
RUN mkdir /home/debian/build

WORKDIR /home/debian/build
RUN apt-get source -o APT::Get::Only-Source=yes \
  nginx=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-geoip=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-image-filter=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-perl=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-xslt=${NGINX_VERSION}-${DEB_BASE_REVISION} \
  nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-${DEB_BASE_REVISION}

WORKDIR /home/debian/build/nginx-${NGINX_VERSION}
RUN debchange -v "${NGINX_VERSION}-1~sid+local1" "Build against sid"
RUN debuild -rfakeroot -uc -us

WORKDIR /home/debian/build/nginx-module-geoip-${NGINX_VERSION}
RUN debchange -v "${NGINX_VERSION}-1~sid+local1" "Build against sid"
RUN debuild -rfakeroot -uc -us

WORKDIR /home/debian/build/nginx-module-image-filter-${NGINX_VERSION}
RUN debchange -v "${NGINX_VERSION}-1~sid+local1" "Build against sid"
RUN debuild -rfakeroot -uc -us

WORKDIR /home/debian/build/nginx-module-perl-${NGINX_VERSION}
RUN debchange -v "${NGINX_VERSION}-1~sid+local1" "Build against sid"
RUN debuild -rfakeroot -uc -us

WORKDIR /home/debian/build/nginx-module-xslt-${NGINX_VERSION}
RUN debchange -v "${NGINX_VERSION}-1~sid+local1" "Build against sid"
RUN debuild -rfakeroot -uc -us

WORKDIR /home/debian/build/nginx-module-njs-${NGINX_VERSION}.${NJS_VERSION}
ADD patches/njs-debian-control.diff /tmp/
RUN debchange -v "${NGINX_VERSION}.${NJS_VERSION}-1~sid+local1" "Build against sid"
RUN patch -p0 < /tmp/njs-debian-control.diff
RUN debuild -rfakeroot -uc -us


RUN mkdir /home/debian/build2
WORKDIR /home/debian/build2
ADD http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz /home/debian/build2/
RUN sudo chown debian:debian /home/debian/build2/nginx-${NGINX_VERSION}.tar.gz
RUN mv nginx-${NGINX_VERSION}.tar.gz nginx-module-mruby_${NGINX_VERSION}.orig.tar.gz
RUN tar xf nginx-module-mruby_${NGINX_VERSION}.orig.tar.gz

WORKDIR /home/debian/build2/nginx-${NGINX_VERSION}

ADD nginx-module-mruby/debian/ debian/

RUN sudo chown -R debian:debian debian

RUN git clone https://github.com/matsumoto-r/ngx_mruby.git debian/extra/ngx_mruby/
RUN cd debian/extra/ngx_mruby && git checkout ${NGX_MRUBY_VERSION}

RUN debchange --create --package nginx-module-mruby -v ${DEB_NGINX_MODULE_MRUBY_VERSION} "Initial release"
RUN debchange --append "nginx ${NGINX_VERSION}, ngx_mruby ${NGX_MRUBY_VERSION}"
RUN debchange -D stable -r ""

RUN debuild -rfakeroot -uc -us


USER root
WORKDIR /home/debian

RUN dpkg -i build/nginx_${NGINX_VERSION}-1~sid+local1_amd64.deb build/nginx-module-njs_${NGINX_VERSION}.${NJS_VERSION}-1~sid+local1_amd64.deb build2/nginx-module-mruby_${DEB_NGINX_MODULE_MRUBY_VERSION}_amd64.deb
RUN apt-get install -f -y --no-install-recommends

ADD nginx-conf.diff /tmp/nginx-conf.diff
RUN cd /etc; patch -p1 < /tmp/nginx-conf.diff && rm /tmp/nginx-conf.diff
RUN /usr/sbin/nginx -t

WORKDIR /
EXPOSE 22 80
ENTRYPOINT ["/opt/init-wrapper/sbin/entrypoint.sh"]
CMD ["/sbin/init"]

