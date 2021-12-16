FROM studionone/apache-php:8.1

ENV VARNISH_VERSION 7.0.1-1~stretch

# Varnish is being installed from source because we need to VCL mod to allow for dynamic configurations
RUN apt-get update && apt-get install -y \
      autoconf \
      automake \
      autotools-dev \
      libedit-dev \
      libjemalloc-dev \
      libncurses-dev \
      libpcre3-dev \
      libvarnishapi-dev \
      libtool \
      pkg-config \
      sphinx-doc \
      sphinx-common \
      apt-transport-https \
      debian-archive-keyring \
      wget

# Add the Varnish Cache gpg key to the keyring used by APT:
RUN wget https://packagecloud.io/varnishcache/varnish70/gpgkey -O - | apt-key add - \
    && echo "deb https://packagecloud.io/varnishcache/varnish70/debian/ stretch main" | tee -a /etc/apt/sources.list.d/varnishcache_varnish70.list \
    && echo "deb-src https://packagecloud.io/varnishcache/varnish70/debian/ stretch main" | tee -a /etc/apt/sources.list.d/varnishcache_varnish70.list \
    && echo "deb http://ftp.au.debian.org/debian stretch main " | tee -a /etc/apt/sources.list # to install libjemalloc1

# Varnish
RUN apt-get update && apt-get install -y --no-install-recommends \
    varnish=$VARNISH_VERSION \
    varnish-dev=$VARNISH_VERSION

# Varnish querystring module
RUN cd /tmp \
    && wget https://github.com/Dridi/libvmod-querystring/releases/download/v2.0.3/vmod-querystring-2.0.3.tar.gz \
    && tar xfz vmod-querystring-2.0.3.tar.gz \
    && rm -rf /tmp/vmod-querystring-2.0.3.tar.gz \
    && cd /tmp/vmod-querystring-2.0.3 \
    && sh configure \
    && make \
    && make install \
    && cd ../ \
    && rm -rf /tmp/vmod-querystring-2.0.3 \
    && ldconfig

# Varnish defult configuration file
COPY conf/default.vcl.m4 /opt/default.vcl.m4
COPY conf/supervisor_conf.d/varnish.conf /etc/supervisor/conf.d/varnish.conf
