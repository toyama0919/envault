require 'spec_helper'
require 'envault'

describe Envault do
  it "escape_yaml" do
    @envs = {
      'USERNAME_A' => 'hogehoge',
      'PASSWORD_A' => 'hogehoge',
      'API_KEY_A' => 'fugafuga'
    }

    yaml = Formatter.escape_yaml(@envs)
    expect(yaml).to eq("USERNAME_A: \"hogehoge\"\nPASSWORD_A: \"hogehoge\"\nAPI_KEY_A: \"fugafuga\"")
  end

  it "escape_yaml not quote" do
    @envs = {
      'USERNAME_A' => 'hogehoge',
      'PASSWORD_A' => 'hogehoge',
      'API_KEY_A' => 'fugafuga'
    }

    yaml = Formatter.escape_yaml(@envs, false)
    expect(yaml).to eq("USERNAME_A: hogehoge\nPASSWORD_A: hogehoge\nAPI_KEY_A: fugafuga")
  end
end
