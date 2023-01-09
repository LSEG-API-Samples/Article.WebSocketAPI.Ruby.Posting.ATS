# Builder stage, for building the source code only
ARG RUBY_VERSION=3.2.0
FROM ruby:${RUBY_VERSION}-slim-bullseye as builder

LABEL maintainer="Developer Advocate"

# Copy Application dependencies
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN apt-get update -y \
    && apt-get install -y build-essential \
    # Application dependencies
    && bundle install \
    # Clean up unnecessary files to reduce Image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Second stage, for running the application in a final image.
ARG VARIANT=alpine
FROM ruby:${RUBY_VERSION}-alpine
LABEL maintainer="Developer Advocate"

#COPY Dependencies 
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Create app directory
WORKDIR /home/app

# Copy Code
COPY src .

# Run application
ENTRYPOINT [ "ruby", "./market_price_postapp.rb" ]
