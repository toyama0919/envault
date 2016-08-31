module Envault
  class Environment < Dotenv::Environment
    def initialize(hash)
      update hash
    end
  end
end
