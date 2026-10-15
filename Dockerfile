ARG RUBY_VERSION=3.4
FROM ruby:${RUBY_VERSION}

WORKDIR /src

# The gemspec shells out to `git ls-files`, and the repo is bind-mounted from the host.
RUN git config --global --add safe.directory /src

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    PATH=/bundle/bin:$PATH

CMD ["bash"]
