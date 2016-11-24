FROM ruby:2.3.1

RUN apt-get update && apt-get install -y locales
RUN dpkg-reconfigure locales && \
locale-gen C.UTF-8 && \
/usr/sbin/update-locale LANG=C.UTF-8
ENV LC_ALL C.UTF-8

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN mkdir -p /usr/src/bundle
ENV BUNDLE_PATH /usr/src/bundle

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install
COPY . /usr/src/app

ENV PORT 5000
CMD ["./scripts/server"]
