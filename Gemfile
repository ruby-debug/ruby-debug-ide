source "http://rubygems.org"

# @param [Array<String>] versions compatible ruby versions
# @return [Array<String>] an array with mri platforms of given versions
def mries(*versions)
  versions.flat_map do |v|
    %w(ruby mingw x64_mingw)
        .map { |platform| "#{platform}_#{v}".to_sym unless platform == "x64_mingw" && v < "2.0" }
        .delete_if &:nil?
  end
end

gem "ruby-debug-base", :platforms => [:jruby, *mries('18')]
gem "ruby-debug-base19x", ">= 0.11.32", :platforms => mries('19')
if RUBY_VERSION && RUBY_VERSION >= "2.0"
  gem "debase", "~> 0.2.2", :platforms => mries('20', '21', '22', '23', '24', '25')
end

gemspec

group :development do
  gem "bundler"
end

group :test do
  gem "test-unit"
end

