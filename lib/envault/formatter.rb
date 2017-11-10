module Envault
  class Formatter
    def self.escape_yaml(hash, quote = true)
      lines = []
      hash.map do |k, v|
        lines << %Q{#{k}: #{quote ? v.inspect : v}}
      end
      lines.join("\n")
    end

    def self.write_escape_yaml(path, hash, quote = true)
      File.write(path, escape_yaml(hash))
    end
  end
end
