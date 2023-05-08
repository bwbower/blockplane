FROM ruby:3.0.2-alpine as builder

RUN apk update && apk upgrade && apk add --no-cache build-base libpq postgresql-dev

WORKDIR /app
COPY . .
RUN gem install bundler:2.3.18
RUN bundle config --local build.pg --with-opt-dir="/usr/local/opt/libpq"
RUN bundle install

EXPOSE 4567

CMD bundle exec ruby main.rb