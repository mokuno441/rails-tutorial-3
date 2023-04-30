# syntax=docker/dockerfile:1
FROM ruby:3.0.1

RUN apt-get update -qq && apt-get install -y postgresql-client
WORKDIR /app
COPY Gemfile /app/Gemfile
RUN bundle install
