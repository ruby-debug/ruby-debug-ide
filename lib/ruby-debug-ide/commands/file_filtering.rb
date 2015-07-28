module Debugger
  class IncludeDir < Command # :nodoc:
    self.control = true

    def regexp
      / ^\s*include\s+(.+?)\s*$/x
    end

    def execute
      file = @match[1]

      return if file.nil?
      file = realpath(file)

      if Command.file_fiter_supported?
        Debugger.file_filter.add(file)
        print_dir_included(file)
      else
        print_debug("file filter is not supported")
      end
    end

    class << self
      def help_command
        'include'
      end

      def help(cmd)
        %{
          file-filter include file - adds dir to list of included dirs
        }
      end
    end
  end
end