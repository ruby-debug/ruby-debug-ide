require 'bundler/gem_tasks'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => [:test]

# Unit tests
Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "test-base"
  t.pattern = 'test/**/*_test.rb'
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

desc "Generates travis.yaml"
task :gen_travis do
  versions = []

  def versions.add(major:, minor:, include_macos: true)
    self << { major: major, minor: [minor], include_macos: include_macos }
  end

  versions.add major: '3.0', minor: 1
  versions.add major: '2.7', minor: 3
  versions.add major: '2.6', minor: 7
  versions.add major: '2.5', minor: 9
  versions.add major: '2.4', minor: 10
  versions.add major: '2.3', minor: 8, include_macos: false
  versions.add major: '2.2', minor: 10, include_macos: false
  versions.add major: '2.1', minor: 10, include_macos: false
  versions.add major: '2.0', minor: 0, include_macos: false
  versions.add major: '1.9', minor: 3, include_macos: false
  versions.add major: '1.8', minor: 7, include_macos: false

  puts <<EOM
language: ruby
dist: trusty
matrix:
  fast_finish: true
  include:
EOM

  loop do
    found_some = false

    versions.each do |version|
      minor = version[:minor].pop
      if minor
        found_some = true
        full_version = "#{version[:major]}.#{minor}"
        puts <<EOM
    - os: linux
      rvm: #{full_version}
EOM
        puts <<EOM if version[:include_macos]
    - os: osx
      rvm: #{full_version}
EOM
      end
    end

    break unless found_some
  end
end