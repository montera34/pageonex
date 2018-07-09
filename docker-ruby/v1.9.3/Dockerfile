FROM debian:jessie-slim

ENV RUBY_VERSION 1.9.3-p551
ENV RUBY_SHA1SUM 5cf6c9383444163a3f753b50c35e441988189258

RUN BUILD_DIR="/tmp/ruby-build" \
 && apt-get update \
 && apt-get -y install \
               wget \
               build-essential \
               zlib1g-dev \
               libssl-dev \
               libreadline6-dev \
               libyaml-dev \
               tzdata \
               libmysqlclient-dev \
               mysql-client \
	       libpq-dev \
	       libxml2-dev \
	       libxslt1-dev \
	       nodejs \
	       libmagickwand-dev \
	       libsqlite3-dev \
 && mkdir -p "$BUILD_DIR" \
 && cd "$BUILD_DIR" \
 && wget -q "http://cache.ruby-lang.org/pub/ruby/ruby-${RUBY_VERSION}.tar.gz" \
 && echo "${RUBY_SHA1SUM}  ruby-${RUBY_VERSION}.tar.gz" | sha1sum -c - \
 && tar xzf "ruby-${RUBY_VERSION}.tar.gz" \
 && cd "ruby-${RUBY_VERSION}" \
 && ./configure --enable-shared --prefix=/usr \
 && make \
 && make install \
 && cd / \
 && rm -r "$BUILD_DIR" \
 && rm -rf /var/lib/apt/lists/*

RUN gem update --system \
    && gem install --force bundler \
    && gem install debugger-ruby_core_source
