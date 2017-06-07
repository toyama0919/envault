require 'dotenv'
require 'pp'
require 'logger'
require 'tempfile'
require 'active_support'

module Envault
  class Core
    attr_accessor :logger, :cryptor, :prefix

    def initialize(config: nil, profile: nil, prefix: nil, debug: false)
      @logger = Logger.new(STDOUT)
      @logger.level = debug ? Logger::DEBUG : Logger::INFO
      profile = get_profile(config, profile)
      @cryptor = if profile[:provider] == 'kms'
        Cryptor::Kms.new(profile)
      else
        Cryptor::Simple.new(profile)
      end
      @prefix = prefix || profile[:prefix] || DEFAULT_ENV_PREFIX
    end

    def encrypt_yaml(path, keys = nil)
      hash = YAML.load_file(path)
      encrypt_process(hash, keys)
    end

    def encrypt_process(hash, keys = nil)
      cipher_keys = get_cipher_keys(hash, keys)
      encrypted = hash.map do |k, v|
        if cipher_keys.include?(k)
          encrypt_value(@prefix + k, v)
        else
          [k, v]
        end
      end
      Hash[encrypted]
    end

    def encrypt_value(key, value)
      [key, @cryptor.encrypt(value)]
    end

    def decrypt_yaml(path)
      hash = YAML.load_file(path)
      decrypt_process(hash)
    end

    def decrypt_process(hash)
      cipher_keys = get_cipher_keys(hash)
      decrypted = hash.map do |k, v|
        if cipher_keys.include?(k)
          decrypt_value(k.gsub(/^#{@prefix}/, ''), v)
        else
          [k, v]
        end
      end
      Hash[decrypted]
    end

    def decrypt_value(key, value)
      [key, @cryptor.decrypt(value)]
    end

    def get_cipher_keys(hash, keys = ["^#{@prefix}.*"])
      all_keys = hash.keys
      if keys
        regexps = []
        keys.each do |key|
          regexps << Regexp.new(key)
        end
        results = regexps.map do |regexp|
          all_keys.select do |key|
            regexp =~ key
          end
        end
        results.flatten
      else
        all_keys
      end
    end

    def load(path = DEFAULT_SOURCE_FILE)
      hash = decrypt_yaml(path)

      Tempfile.create("dotenv-vault") do |f|
        Formatter.write_escape_yaml(f.path, hash)
        Dotenv.load(f.path)
      end
    end

    private

    def get_cryptor(passphrase, sign_passphrase, salt)
      key = ActiveSupport::KeyGenerator.new(passphrase).generate_key(salt, 32)
      signature_key = ActiveSupport::KeyGenerator.new(sign_passphrase).generate_key(salt, 32) if sign_passphrase

      if signature_key
        ActiveSupport::MessageEncryptor.new(key, signature_key, cipher: DEFAULT_CIPHER, digest: DEFAULT_DIGEST)
      else
        ActiveSupport::MessageEncryptor.new(key, cipher: DEFAULT_CIPHER, digest: DEFAULT_DIGEST)
      end
    end

    def get_profile(config_path, profile_name)
      return get_profile_form_env unless config_path
      config = YAML.load_file(config_path)
      return get_profile_form_env unless config
      profile = config[profile_name]
      unless profile
        raise %Q{invalid profile [#{profile_name}].}
      end
      if profile['provider'] == 'kms'
        {
          provider: profile['provider'],
          key_id: profile['key_id'],
          prefix: profile['prefix']
        }
      else
        {
          passphrase: profile['passphrase'],
          sign_passphrase: profile['sign_passphrase'],
          salt: profile['salt'],
          prefix: profile['prefix']
        }
      end
    end

    def get_profile_form_env
      {
        passphrase: ENV['ENVAULT_PASSPHRASE'],
        sign_passphrase: ENV['ENVAULT_SIGN_PASSPHRASE'],
        salt: ENV['ENVAULT_SALT'],
        prefix: ENV['ENVAULT_PREFIX']
      }
    end
  end
end
