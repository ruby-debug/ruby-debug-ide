module Debugger
  class IncludeFile < Command # :nodoc:
    self.control = true

    def regexp
      / ^\s*include\s+(.+?)\s*$/x
    end

    def execute
      file = @match[1]

      return if file.nil?
      file = realpath(file)

      if Command.file_filter_supported?
        Debugger.file_filter.include(file)
        print_file_included(file)
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
          include file - adds file/dir to file filter (either remove already excluded or add as included)
        }
      end
    end
  end

  class ExcludeFile < Command # :nodoc:
    self.control = true

    def regexp
      / ^\s*exclude\s+(.+?)\s*$/x
    end

    def execute
      file = @match[1]

      return if file.nil?
      file = realpath(file)

      if Command.file_filter_supported?
        Debugger.file_filter.exclude(file)
        print_file_excluded(file)
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
          exclude file - exclude file/dir from file filter (either remove already included or add as exclude)
        }
      end
    end
  end
end