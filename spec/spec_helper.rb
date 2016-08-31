require 'rspec'
require 'envault/version'

include Envault

def capture_stdout
  out = StringIO.new
  $stdout = out
  yield
  return out.string
ensure
  $stdout = STDOUT
end

def capture_stderr
  out = StringIO.new
  $stderr = out
  yield
  return out.string
ensure
  $stderr = STDERR
end

def clear_env
  ENV['ENVAULT_PASSPHRASE'] = nil
  ENV['ENVAULT_SIGN_PASSPHRASE'] = nil
  ENV['ENVAULT_SALT'] = nil
  ENV['ENVAULT_PREFIX'] = nil
end
