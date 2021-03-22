# docker build -t rdebug-ide .
# docker run --rm rdebug-ide rake
# docker run -it --rm -e RUBYLIB=/mounted/lib/ -p 127.0.0.1:1234:1234 -v $PWD:/mounted -w /mounted rdebug-ide bash

# Maybe you prefer jruby?
# docker build --build-arg IMAGE=jruby --build-arg TAG=latest -t rdebug-ide .
ARG IMAGE=ruby
ARG TAG=3.0
FROM ${IMAGE}:${TAG}

WORKDIR /src

COPY Gemfile .
COPY *.gemspec .
COPY lib/ruby-debug-ide/version.rb ./lib/ruby-debug-ide/version.rb

RUN bundle

COPY . .
