FROM ubuntu:14.04
MAINTAINER talkingquickly.co.uk <ben@talkingquickly.co.uk>

ENV DEBIAN_FRONTEND noninteractive

# INSTALL
RUN apt-get update -y --fix-missing
RUN apt-get install -y --fix-missing -q \
  autoconf \
  automake \
  bison \
  build-essential \
  curl \
  git-core \
  libc6-dev \
  libffi-dev \
  libssl-dev \
  libtool \
  libyaml-dev \
  libxml2-dev \
  make \
  ncurses-dev \
  nodejs \
  openjdk-7-jdk \
  openssl \
  pkg-config \
  postgresql-client \
  unzip \
  vim \
  wget \
  xvfb

# Get ruby-build
RUN git clone https://github.com/sstephenson/ruby-build.git /tmp/ruby-build && \
    cd /tmp/ruby-build && \
    ./install.sh && \
    cd / && \
    rm -rf /tmp/ruby-build

# List available rubies
RUN ruby-build --definitions

# Install ruby
RUN ruby-build -v jruby-1.7.13 /usr/local

# Install base gems
RUN gem install bundler rubygems-bundler --no-rdoc --no-ri

# Regenerate binstubs
RUN gem regenerate_binstubs

# Rails app code
ADD docker/rails/start-server.sh /start-server.sh
RUN chmod +x /start-server.sh
RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --retry 3
ADD . /app

# default to development mode. Override by setting RAILS_ENV in the bash environment.
ENV RAILS_ENV development

EXPOSE 3000

# Server startup
CMD ["/start-server.sh"]
