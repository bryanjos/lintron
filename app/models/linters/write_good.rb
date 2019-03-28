module Linters
  class WriteGood < Linters::Base
    def run(file)
      lint_string = IO.popen(cmd(file), 'r+') do |f|
        f.puts file.blob
        f.close_write
        f.read
      end

      begin
        lints = JSON.parse(lint_string).first['suggestions']
        lints.map do |lint|
          Violation.new(file: file, line: lint['index'], message: lint['reason'], linter: Linters::WriteGood)
        end
      rescue JSON::ParserError
        [
          Violation.new(
            file: file,
            line: (file.patch.changed_lines.first.number rescue 1),
            message: 'Unexpected error in WriteGood',
            linter: Linters::WriteGood,
          ),
        ]
      end
    end

    def cmd(file)
      <<-CMD.squish
      node src/linters/writeGood.js 2>&1
      CMD
    end
  end
end

Linters.register(:md, Linters::WriteGood)
Linters.register(:txt, Linters::WriteGood)
