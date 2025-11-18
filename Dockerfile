ARG RUBY_VERSION=2.7.8
FROM ruby:${RUBY_VERSION}

ARG BUNDLE_GEMFILE_ARG=Gemfile
ENV BUNDLE_GEMFILE=${BUNDLE_GEMFILE_ARG}
# Install and use an compatible bundler
ARG BUNDLER_VERSION_ARG=1.17.3
ENV BUNDLER_VERSION=${BUNDLER_VERSION_ARG}
RUN gem install bundler $(test "$(echo ${RUBY_VERSION} | cut -d. -f1)" -lt "3" && echo -v "${BUNDLER_VERSION}")

# Install required gems before copying in code
# to avoid re-installing gems when developing
WORKDIR /app
COPY Gemfile* /app
COPY aptible-cli.gemspec /app

# We reference the version, so copy that in, too
RUN mkdir -p /app/lib/aptible/cli/
COPY lib/aptible/cli/version.rb /app/lib/aptible/cli/

RUN bundle install

COPY . /app

# Save on typing while testing
RUN echo '#!/bin/bash' > /usr/bin/aptible \
 && echo 'bundle exec bin/aptible $@' >> /usr/bin/aptible \
 && chmod +x /usr/bin/aptible

CMD ["aptible"]
