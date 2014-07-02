require 'stringio'
require 'irb/ruby-lex'

module Debugger

  class ExpressionInfoCommand < Command
    def regexp
      /^\s*ex(?:pression_info)?\s+/
    end

    def execute
      string_to_parse = @match.post_match.gsub("\\n", "\n") + "\n\n\n"

      lexer = RubyLex.new
      io = StringIO.new(string_to_parse)
      # for passing to the lexer
      io.instance_exec(string_to_parse.encoding) do |string_encoding|
        @my_encoding = string_encoding
        def self.encoding
          @my_encoding
        end
      end

      lexer.set_input(io)
      lexer.set_prompt {|ltype, indent, continue, lineno| }

      last_statement = ''
      lexer.each_top_level_statement do |line, line_no|
        last_statement = line
      end

      incomplete = true
      if /\A\s*\Z/m =~ last_statement[0]
        incomplete = false
      end

      @printer.print_pp("<expressionInfo incomplete=\"#{incomplete.to_s}\"></expressionInfo>")
    end

    class << self
      def help_command
        "expression_info"
      end

      def help(cmd)
        %{
          ex[pression_info] <expression>\t
          returns parser-related information for the expression given\t\t
          'incomplete'=true|false\tindicates whether expression is a complete ruby
          expression and can be evaluated without getting syntax errors
        }
      end
    end
  end

end
