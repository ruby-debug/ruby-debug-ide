[![Gem Version](https://badge.fury.io/rb/ruby-debug-ide.svg)][gem]
[![Build Status](https://travis-ci.org/ruby-debug/ruby-debug-ide.svg?branch=master)](https://travis-ci.org/ruby-debug/ruby-debug-ide)

[gem]: https://rubygems.org/gems/ruby-debug-ide
# ruby-debug-ide

The 'ruby-debug-ide' gem provides the protocol to establish communication between the debugger engine (such as [debase](https://rubygems.org/gems/debase) or [ruby-debug-base](https://rubygems.org/gems/ruby-debug-base)) and IDEs (for example, RubyMine, Visual Studio Code, or Eclipse). 'ruby-debug-ide' redirect commands from the IDE to the debugger engine. Then, it returns answers/events received from the debugger engine to the IDE. To learn more about a communication protocol, see the following document: [ruby-debug-ide protocol](protocol-spec.md).

## Install debugging gems
Depending on the used Ruby version, you need to add/install the following debugging gems to the Gemfile:
- Ruby 2.x - [ruby-debug-ide](https://rubygems.org/gems/ruby-debug-ide) and [debase](https://rubygems.org/gems/debase)
- Ruby 1.9.x - [ruby-debug-ide](https://rubygems.org/gems/ruby-debug-ide) and [ruby-debug-base19x](https://rubygems.org/gems/ruby-debug-base19x)
- jRuby or Ruby 1.8.x - [ruby-debug-ide](https://rubygems.org/gems/ruby-debug-ide) and [ruby-debug-base](https://rubygems.org/gems/ruby-debug-base)
> For Windows, make sure that the Ruby [DevKit](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit) is installed.
  
## Start debugging session
To start the debugging session for a Rails application, run the following command:
```shell
rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 1234 -- bin/rails s
```
If you want to debug a Rails application run using Docker Compose, you need to start the Rails server from the Docker in the following way:
```yaml
command: bundle exec rdebug-ide --host 0.0.0.0 --port 1234 -- bin/rails s -p 3000 -b 0.0.0.0
volumes: 
  - .:/sample_rails_app
ports:
  - "1234:1234"
  - "3000:3000"
  - "26162:26162"
```
Note that all ports above should be exposed in the Dockerfile.