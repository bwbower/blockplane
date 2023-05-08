FROM ruby:3.0.2-alpine as builder

RUN apk update && apk upgrade && apk add --no-cache build-base

WORKDIR /app
COPY . .
RUN gem install bundler:2.3.18
RUN apk add postgresql postgresql-dev postgresql-client
RUN bundle install
RUN service postgresql start
RUN ./db/reset

EXPOSE 4567

CMD bundle exec ruby main.rb