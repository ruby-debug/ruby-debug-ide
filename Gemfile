source "http://rubygems.org"

# Need to limit Debase to 0.2.2 for Ruby 2.0 so the tests
# pass but it appears that Debase 2.4 will work when Debase
# is using in a project.  The error in the tests is:
#
#   Error: test_catchpoint_basics(RDCatchpointTest): RuntimeError: expected "suspended" start_element, but got "end_document: []"
#
if RUBY_VERSION
  if RUBY_VERSION < "1.9"
    gem "ruby-debug-base"
  elsif RUBY_VERSION < "2.0"
    gem "ruby-debug-base19x", ">= 0.11.32"
  elsif RUBY_VERSION < "2.1"
    gem "debase", "<= 0.2.2"
  else
    gem "debase", ">= 0.2.2"
  end
end

gemspec

group :development, :test do
  # Bundler 1.9.0 has an error on Ruby 1.9.3:
  #
  #  https://github.com/rubygems/bundler/issues/3492
  #
  gem "bundler", "> 1.9"

  if RUBY_VERSION < "1.9"
    gem "test-unit", "~> 2.1.2"
  else
    gem "test-unit"
  end

  gem "standard"
end
