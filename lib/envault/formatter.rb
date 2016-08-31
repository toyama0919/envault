module Envault
  class Formatter
    def self.escape_yaml(hash)
      lines = []
      hash.map do |k, v|
        lines << %Q{#{k}: #{v.inspect}}
      end
      lines.join("\n")
    end

    def self.write_escape_yaml(path, hash)
      File.write(path, escape_yaml(hash))
    end
  end
end
