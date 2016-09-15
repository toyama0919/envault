module Envault
  DEFAULT_SOURCE_FILE = ".env"
  DEFAULT_ENV_PREFIX = "ENVAULT_"
  DEFAULT_CIPHER = "aes-256-cbc"
  DEFAULT_DIGEST = "SHA256"
  SKIP_INITIALIZE_commands = ["reencrypt_file"]
end
