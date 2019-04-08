FROM studionone/apache-php:7.3

# Varnish is being installed from source because we need to VCL mod to allow for dynamic configurations
RUN apt-get update && apt-get install -y autoconf \
      automake \
      autotools-dev \
      libedit-dev \
      libjemalloc-dev \
      libncurses-dev \
      libpcre3-dev \
      libtool \
      pkg-config \
      python-docutils \
      python-sphinx \
      apt-transport-https \
      wget

# Add the Varnish Cache gpg key to the keyring used by APT:
RUN wget https://packagecloud.io/varnishcache/varnish60lts/gpgkey -O - | apt-key add - \
    && apt-get install apt-transport-https debian-archive-keyring -y \
    && echo "deb https://packagecloud.io/varnishcache/varnish60lts/debian/ stretch main" | tee -a /etc/apt/sources.list.d/varnishcache_varnish60lts.list \
    && echo "deb-src https://packagecloud.io/varnishcache/varnish60lts/debian/ stretch main" | tee -a /etc/apt/sources.list.d/varnishcache_varnish60lts.list

# Varnish
RUN apt-get update && apt-get install -y \
     varnish \
     varnish-dev \
    && cd /tmp \
      && wget https://github.com/Dridi/libvmod-querystring/releases/download/v2.0.1/vmod-querystring-2.0.1.tar.gz \
      && tar xfz vmod-querystring-2.0.1.tar.gz \
      && rm -rf /tmp/vmod-querystring-2.0.1.tar.gz

# Varnish querystring module
RUN cd /tmp/vmod-querystring-2.0.1 \
      && sh configure \
      && make \
      && make install \
      && cd ../ \
      && rm -rf /tmp/vmod-querystring-2.0.1 \
      && ldconfig

# Varnish defult configuration file
COPY conf/default.vcl.m4 /opt/default.vcl.m4
COPY conf/supervisor_conf.d/varnish.conf /etc/supervisor/conf.d/varnish.conf

