jruby = defined?(JRUBY_VERSION) || (defined?(RUBY_ENGINE) && 'jruby' == RUBY_ENGINE)
unless jruby
  require 'rubygems'
  require 'rubygems/command.rb'
  require 'rubygems/dependency.rb'
  require 'rubygems/dependency_installer.rb'

  begin
    Gem::Command.build_args = ARGV
    rescue NoMethodError
  end

  if RUBY_VERSION < "1.9"
    dep = Gem::Dependency.new("ruby-debug-base", '>=0.10.4')
  else
    dep = Gem::Dependency.new("ruby-debug-base19x", '>=0.11.24')
  end

  inst = Gem::DependencyInstaller.new
  begin
    inst.install dep
  rescue
    inst = Gem::DependencyInstaller.new(:prerelease => true)
    begin
      inst.install dep
    rescue Exception => e
      puts e
      puts e.backtrace.join "\n  "
      exit(1)
    end
  end
end

# create dummy rakefile to indicate success
f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")
f.write("task :default\n")
f.close

