module Debugger

  class InspectCommand < Command
    # reference inspection results in order to save them from the GC
    @@references = []
    def self.reference_result(result)
      @@references << result
    end
    def self.clear_references
      @@references = []
    end
    
    def regexp
      /^\s*v(?:ar)?\s+inspect\s+/
    end
    #    
    def execute
      binding = @state.context ? get_binding : TOPLEVEL_BINDING
      obj = debug_eval(@match.post_match, binding)
      InspectCommand.reference_result(obj)
      @printer.print_inspect(obj)
    end
  end

  class MoreCommand < Command
    def regexp
      /^\s*more\s+/
    end

    def execute
      require 'stringio'
      require 'irb/ruby-lex'

      string_to_parse = @match.post_match.gsub("\\n", "\n") + "\n\n\n"

      lexer = RubyLex.new
      io = StringIO.new(string_to_parse)
      # for passing to the lexer
      def io.encoding
        "utf-8"
      end
      lexer.set_input(io)
      lexer.set_prompt {|ltype, indent, continue, lineno| }

      last_statement = '',0
      lexer.each_top_level_statement do |line, line_no|
        last_statement = line, line_no
      end

      result = 1
      if /\A\s*\Z/m =~ last_statement[0]
        result = 0
      end

      @printer.print_pp("<more value=\"#{result.to_s}\"></more>")
    end
  end

end
