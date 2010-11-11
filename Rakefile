require 'rubygems'

require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'lib/ruby-debug/version'
require 'date'

desc 'Default: run unit tests.'
task :default => [:test]

# ------- Default Package ----------
RUBY_DEBUG_IDE_VERSION = Debugger::IDE_VERSION

FILES = FileList[
#  'CHANGES',
#  'ChangeLog',
#  'ChangeLog.archive',
  'MIT-LICENSE',
  'Rakefile',
  'bin/*',
  'lib/**/*',
#  'test/**/*',
  'ext/mkrf_conf.rb'
]

ide_spec = Gem::Specification.new do |spec|
  spec.name = "ruby-debug-ide"

  spec.homepage = "http://rubyforge.org/projects/debug-commons/"
  spec.summary = "IDE interface for ruby-debug."
  spec.description = <<-EOF
An interface which glues ruby-debug to IDEs like Eclipse (RDT), NetBeans and RubyMine.
EOF

  spec.version = RUBY_DEBUG_IDE_VERSION

  spec.author = "Markus Barchfeld, Martin Krauskopf, Mark Moseley, JetBrains RubyMine Team"
  spec.email = "rubymine-feedback@jetbrains.com"
  spec.platform = Gem::Platform::RUBY
  spec.require_path = "lib"
  spec.bindir = "bin"
  spec.executables = ["rdebug-ide"]
  spec.files = FILES.to_a

  spec.extensions << "ext/mkrf_conf.rb"
  spec.add_dependency("rake", ">= 0.8.1")

  spec.required_ruby_version = '>= 1.8.2'
  spec.date = DateTime.now
  spec.rubyforge_project = 'debug-commons'

  # rdoc
  spec.has_rdoc = false
end

# Rake task to build the default package
Rake::GemPackageTask.new(ide_spec) do |pkg|
  pkg.need_tar = true
end

# Unit tests
Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "test-base"
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = false
end


desc "Create a GNU-style ChangeLog via svn2cl"
task :ChangeLog do
  system("svn2cl --authors=svn2cl_usermap svn://rubyforge.org/var/svn/debug-commons/ruby-debug-ide/trunk -o ChangeLog")
end

#desc "Publish ruby-debug to RubyForge."
#task :publish do
#  require 'rake/contrib/sshpublisher'
#
#  # Get ruby-debug path
#  ruby_debug_path = File.expand_path(File.dirname(__FILE__))
#
#  publisher = Rake::SshDirPublisher.new("kent@rubyforge.org",
#        "/var/www/gforge-projects/ruby-debug", ruby_debug_path)
#end
#
#desc "Clear temp files"
#task :clean do
#  cd "ext" do
#    if File.exists?("Makefile")
#      sh "make clean"
#      rm "Makefile"
#    end
#  end
#end
#
## ---------  RDoc Documentation ------
#desc "Generate rdoc documentation"
#Rake::RDocTask.new("rdoc") do |rdoc|
#  rdoc.rdoc_dir = 'doc'
#  rdoc.title    = "ruby-debug"
#  # Show source inline with line numbers
#  rdoc.options << "--inline-source" << "--line-numbers"
#  # Make the readme file the start page for the generated html
#  rdoc.options << '--main' << 'README'
#  rdoc.rdoc_files.include('bin/**/*',
#                          'lib/**/*.rb',
#                          'ext/**/ruby_debug.c',
#                          'README',
#                          'LICENSE')
#end
