require 'rubygems'

require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
if RUBY_VERSION < "1.9"
  require 'lib/ruby-debug/version'
else
  require_relative 'lib/ruby-debug/version'
end
require 'date'

desc 'Default: run unit tests.'
task :default => [:test]

# ------- Default Package ----------
RUBY_DEBUG_IDE_VERSION = Debugger::IDE_VERSION

FILES = FileList[
  'CHANGES',
  'ChangeLog',
  'ChangeLog.archive',
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

  spec.extensions << "ext/mkrf_conf.rb" unless ENV['NO_EXT']
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


desc "Create a ChangeLog"
# simple rake task to output a changelog between two commits, tags ...
# output is formatted simply, commits are grouped under each author name
desc "generate changelog with nice clean output"
task :changelog, :since_c, :until_c do |t,args|
  since_c = args[:since_c] || `git tag | head -1`.chomp
  until_c = args[:until_c]
  cmd=`git log --pretty='format:%ci::%an <%ae>::%s::%H' #{since_c}..#{until_c}`

  entries = Hash.new
  changelog_content = String.new

  cmd.split("\n").each do |entry|
    date, author, subject, hash = entry.chomp.split("::")
    entries[author] = Array.new unless entries[author]
    day = date.split(" ").first
    entries[author] << "#{subject} (#{hash})" unless subject =~ /Merge/
  end

  # generate clean output
  entries.keys.each do |author|
    changelog_content += author + "\n"
    entries[author].reverse.each { |entry| changelog_content += "  * #{entry}\n" }
  end

  puts changelog_content
end