#!/bin/bash

set -e

bundle check || bundle install
bundle clean --force

exec "$@"