require 'spec_helper'
require 'envault'

describe Envault::CLI do
  before do
    clear_env
    ENV['ENVAULT_PASSPHRASE'] = 'ENV'
    ENV['ENVAULT_SIGN_PASSPHRASE'] = 'ENV'
    ENV['ENVAULT_SALT'] = 'ENV'
  end

  it "should stdout help" do
    output = capture_stdout do
      Envault::CLI.start(['help'])
    end
    expect(output).not_to eq(nil)
  end

  it "encrypt options" do
    output = capture_stdout do
      Envault::CLI.start(['help', 'encrypt'])
    end
    expect(output).to include('-s,')
    expect(output).to include('-c,')
    expect(output).to include('-p,')
  end

  it "decrypt options" do
    output = capture_stdout do
      Envault::CLI.start(['help', 'decrypt'])
    end
    expect(output).to include('-s,')
    expect(output).to include('-c,')
    expect(output).to include('-p,')
  end

  after do
  end
end
