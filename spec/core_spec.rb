require 'spec_helper'
require 'envault'

describe Envault::Core do

  before do
    clear_env
    @config_path = File.expand_path("../config/envault.yml", __FILE__)
    @core = Core.new(config: @config_path, profile: 'a')
    @envs = {
      'USERNAME_A' => 'hogehoge',
      'PASSWORD_A' => 'hogehoge',
      'API_KEY_A' => 'fugafuga'
    }
    @encrypted = @core.encrypt_process(@envs, ['PASSWORD_A', 'API_KEY_A'])
  end

  it "core not nil" do
    expect(@core).not_to eq(nil)
  end

  it "exist logger" do
    expect(@core.logger).not_to eq(nil)
  end

  describe 'profile ok case' do
    it "encrypt envs" do
      expect(@encrypted.keys).to eq(['USERNAME_A', 'ENVAULT_PASSWORD_A', 'ENVAULT_API_KEY_A'])
      expect(@encrypted['USERNAME_A']).to eq('hogehoge')
      expect(@encrypted['ENVAULT_PASSWORD_A']).not_to eq('hogehoge')
      expect(@encrypted['ENVAULT_API_KEY_A']).not_to eq('hogehoge')
    end

    it "decrypt envs" do
      expect(@core.decrypt_process(@encrypted)).to include(@envs)
    end

    it "decrypt envs other instance" do    
      other = Core.new(config: @config_path, profile: 'a')
      expect(other.decrypt_process(@encrypted)).to include(@envs)
    end
  end

  describe 'profile error case' do
    it "cannot encrypt 1" do
      other = Core.new(config: @config_path, profile: 'a1')
      expect {
        other.decrypt_process(@encrypted)
      }.to raise_exception(ActiveSupport::MessageEncryptor::InvalidMessage)
    end

    it "cannot encrypt 2" do
      other = Core.new(config: @config_path, profile: 'a2')
      expect {
        other.decrypt_process(@encrypted)
      }.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)
    end

    it "cannot encrypt 3 no salt" do
      other = Core.new(config: @config_path, profile: 'a3')
      expect {
        other.decrypt_process(@encrypted)
      }.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)
    end

    it "cannot encrypt 4 different sign_passphrase" do
      other = Core.new(config: @config_path, profile: 'a4')
      expect {
        other.decrypt_process(@encrypted)
      }.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)
    end

    it "cannot encrypt 5 different sign_passphrase" do
      other = Core.new(config: @config_path, profile: 'a5')
      expect {
        other.decrypt_process(@encrypted)
      }.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)
    end

    it "cannot encrypt" do
      other = Core.new(config: @config_path, profile: 'b')
      expect {
        other.decrypt_process(@encrypted)
      }.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)
    end
  end

  describe 'environment variables' do
    it "environment variables decrypt" do
      ENV['ENVAULT_PASSPHRASE'] = 'p1'
      ENV['ENVAULT_SIGN_PASSPHRASE'] = 'sp1'
      ENV['ENVAULT_SALT'] = 's1'
      ENV['ENVAULT_PREFIX'] = 'ENVAULT_'
      other = Core.new
      expect(other.decrypt_process(@encrypted)).to include(@envs)
      clear_env
    end

    it "environment variables decrypt other prefix" do
      ENV['ENVAULT_PASSPHRASE'] = 'p1'
      ENV['ENVAULT_PREFIX'] = 'ENVAULT_OTHER_PREFIX_'
      other = Core.new
      decrypted = other.decrypt_process(@encrypted)
      expect(@encrypted['USERNAME_A']).to eq('hogehoge')
      expect(decrypted['ENVAULT_PASSWORD_A']).not_to eq('hogehoge')
      expect(decrypted['ENVAULT_API_KEY_A']).not_to eq('fugafuga')
      clear_env
    end

    it "environment variables cannot decrypt" do
      ENV['ENVAULT_PASSPHRASE'] = 'p1'
      ENV['ENVAULT_PREFIX'] = 'ENVAULT_'
      other = Core.new
      expect {
        other.decrypt_process(@encrypted)
      }.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)
      clear_env
    end

    it "environment variables cannot decrypt no salt" do
      ENV['ENVAULT_PASSPHRASE'] = 'p1'
      ENV['ENVAULT_SIGN_PASSPHRASE'] = 'sp1'
      ENV['ENVAULT_PREFIX'] = 'ENVAULT_'
      other = Core.new
      expect {
        other.decrypt_process(@encrypted)
      }.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)
      clear_env
    end

    it "environment variables cannot decrypt no passphrase" do
      ENV['ENVAULT_SIGN_PASSPHRASE'] = 'sp1'
      ENV['ENVAULT_SALT'] = 's1'
      ENV['ENVAULT_PREFIX'] = 'ENVAULT_'
      other = Core.new
      expect {
        other.decrypt_process(@encrypted)
      }.to raise_exception(ActiveSupport::MessageEncryptor::InvalidMessage)
      clear_env
    end
  end

  after do
  end
end
