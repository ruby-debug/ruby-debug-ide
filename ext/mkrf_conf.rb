jruby = defined?(JRUBY_VERSION) || (defined?(RUBY_ENGINE) && 'jruby' == RUBY_ENGINE)
unless jruby
  require 'rubygems'
  require 'rubygems/command.rb'
  require 'rubygems/dependency_installer.rb'

  begin
    Gem::Command.build_args = ARGV
    rescue NoMethodError
  end

  inst = Gem::DependencyInstaller.new
  begin
    if RUBY_VERSION < "1.9"
      inst.install "ruby-debug-base", '>=0.10.4'
    else
      inst.install "ruby-debug-base19", '>=0.11.24'
    end
    rescue
      exit(1)
  end
end

# create dummy rakefile to indicate success
f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")
f.write("task :default\n")
f.close

