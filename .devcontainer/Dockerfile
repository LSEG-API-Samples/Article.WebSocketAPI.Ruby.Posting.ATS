# Dockerfile for the devcontainer. This image is for building a devcontainer only
ARG RUBY_VERSION=3.2.0
ARG VARIANT=bullseye
FROM ruby:${RUBY_VERSION}-${VARIANT}

LABEL maintainer="Developer Advocate"

# Create app directory
WORKDIR /app

# Install dependencies
RUN apt-get update -y \
    && apt-get install -y build-essential \
    # Clean up unnecessary files to reduce Image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#Run default shell
CMD ["/bin/bash"]
