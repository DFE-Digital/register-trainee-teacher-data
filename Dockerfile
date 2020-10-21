FROM ruby:2.7.2-alpine

RUN apk add --update --no-cache tzdata && \
  cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
  echo "Europe/London" > /etc/timezone

RUN apk add --update --no-cache --virtual runtime-dependances \
  postgresql-dev \
  yarn

WORKDIR /tmp
COPY .tool-versions Gemfile Gemfile.lock /tmp/

RUN apk add --update --no-cache --virtual build-dependances \
  build-base && \
  bundle install --jobs=4 && \
  apk del build-dependances

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

RUN bundle exec rake assets:precompile

CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0
