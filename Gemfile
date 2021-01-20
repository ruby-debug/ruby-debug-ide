source "http://rubygems.org"

if RUBY_VERSION
  if RUBY_VERSION < "1.9"
    gem "ruby-debug-base"
  elsif RUBY_VERSION < "2.0"
    gem "ruby-debug-base19x", ">= 0.11.32"
  else RUBY_VERSION >= "2.0"
    gem "debase", ">= 0.2.2"
  end
end

gemspec

group :development, :test do
  gem "bundler"

  if RUBY_VERSION < "1.9"
    gem "test-unit", "~> 2.1.2"
  else
    gem "test-unit"
  end
end
