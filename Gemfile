source "http://rubygems.org"

# @param [Array<String>] versions compatible ruby versions
# @return [Array<String>] an array with mri platforms of given versions
def mries(*versions)
  versions.map do |v|
    %w(ruby mingw x64_mingw).map do |platform|
      "#{platform}_#{v}".to_sym unless platform == "x64_mingw" && v < "2.0"
    end.delete_if &:nil?
  end.flatten
end

if RUBY_VERSION < '1.9' || defined?(JRUBY_VERSION)
  gem "ruby-debug-base", :platforms =>  [:jruby, *mries('18')]
end

if RUBY_VERSION && RUBY_VERSION >= "1.9" && RUBY_VERSION < "2.0"
  gem "ruby-debug-base19x", ">= 0.11.32"
end

if RUBY_VERSION && RUBY_VERSION >= "2.0"
  gem "debase", "~> 0.2", ">= 0.2.9"
end

gemspec

group :development do
  gem "bundler"
end

group :test do
  if RUBY_VERSION < "1.9"
    gem "test-unit", "~> 2.1.2"
  else
    gem "test-unit"
  end
end

