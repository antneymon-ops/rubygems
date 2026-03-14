FROM ruby:3.3-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libsqlite3-dev \
      curl \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock* ./
RUN bundle install --without development test

COPY . .

RUN mkdir -p db

EXPOSE 3001

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3001", "config.ru"]
