def load_debugger(gems_to_include, new_argv)
  path_to_rdebug = File.expand_path(File.dirname(__FILE__)) + '/../../../bin/rdebug-ide'

  old_argv = ARGV.clone
  ARGV.clear
  new_argv.each do |x|
    ARGV << x
  end

  gems_to_include.each do |gem_path|
    $LOAD_PATH.unshift(gem_path) unless $LOAD_PATH.include?(gem_path)
  end

  load path_to_rdebug
  
  ARGV.clear
  old_argv.each do |x|
    ARGV << x
  end
end
