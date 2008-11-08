#!/bin/sh

# You may pass -n options to say that the user has all needed access and 'sudo'
# is not needed

echo "Installing"
[ -d pkg ] && rm -r pkg
rake package
gem_command="gem install -l pkg/ruby-debug-ide-0.4.1.gem"
if [ "$1" = "-n" ]; then
  eval "$gem_command"
else
  eval "sudo $gem_command"
fi
