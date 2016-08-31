require 'thor'
require 'erb'
require 'yaml'

module Envault
  class CLI < Thor
    map '-e' => :encrypt_file
    map '-d' => :decrypt_file
    map '-r' => :reencrypt_file

    class_option :config, aliases: '-c', type: :string ,desc: 'config'
    class_option :profile, aliases: '-p', type: :string, default: 'default',desc: 'profile'
    class_option :debug, aliases: '--debug', type: :boolean, default: false, desc: 'debug'
    class_option :prefix, type: :string, default: nil, desc: 'prefix'
    def initialize(args = [], options = {}, config = {})
      super(args, options, config)
      @class_options = config[:shell].base.options
      @core = Core.new(
        config: @class_options['config'],
        profile: @class_options['profile'],
        prefix: @class_options['prefix'],
        debug: @class_options['debug']
      )
      @logger = @core.logger
    end

    desc "encrypt", "encrypt string"
    option :source, aliases: '-s', type: :string, required: true, desc: 'source', banner: 'source'
    def encrypt
      puts @core.cryptor.encrypt_and_sign(options['source'])
    end

    desc "decrypt", "decrypt string"
    option :source, aliases: '-s', type: :string, required: true, desc: 'source'
    def decrypt
      puts @core.cryptor.decrypt_and_verify(options['source'])
    end

    desc "reencrypt_file", "reencrypt_file"
    option :source, aliases: '-s', type: :string, required: true, desc: 'source'
    option :from_profile, type: :string, required: true, desc: 'from_profile'
    option :to_profile, type: :string, required: true, desc: 'to_profile'
    def reencrypt_file
      yaml = YAML.load_file(options['source'])
      from = Core.new(
        config: @class_options['config'],
        profile: options['from_profile'],
        prefix: @class_options['prefix'],
        debug: @class_options['debug']
      )
      cipher_keys = from.get_cipher_keys(yaml).map{ |cipher_key| cipher_key.gsub(/^#{from.prefix}/, '') }
      decrypted = from.decrypt_yaml(options['source'])
      to = Core.new(
        config: @class_options['config'],
        profile: options['to_profile'],
        prefix: @class_options['prefix'],
        debug: @class_options['debug']
      )
      puts Formatter.escape_yaml(to.encrypt_process(decrypted, cipher_keys))
    end

    desc "encrypt_file", "exp. envault -e -s .env -k '^PASSWORD_.*' '^API_KEY_.*'"
    option :source, aliases: '-s', type: :array, required: true, desc: 'secret'
    option :keys, aliases: '-k', type: :array, required: false, desc: 'keys'
    option :plain_text, aliases: '-t', type: :array, default: [], required: false, desc: 'plain'
    def encrypt_file
      result = {}
      options['plain_text'].each do |plain_text_path|
        result = result.merge(YAML.load(ERB.new(File.read(plain_text_path)).result))
      end
      options['source'].each do |secret_yaml_path|
        result = result.merge(@core.encrypt_yaml(secret_yaml_path, options['keys']))
      end
      puts Formatter.escape_yaml(result)
    end

    desc "decrypt_file", "exp. envault -d -s .env"
    option :source, aliases: '-s', type: :array, required: true, desc: 'source'
    option :plain_text, aliases: '-t', type: :array, default: [], required: false, desc: 'plain_text'
    def decrypt_file
      result = {}
      options['plain_text'].each do |plain_text_path|
        result = result.merge(YAML.load(ERB.new(File.read(plain_text_path)).result))
      end
      options['source'].each do |encrypt_yaml_path|
        result = result.merge(@core.decrypt_yaml(encrypt_yaml_path))
      end
      puts Formatter.escape_yaml(result)
    end

    desc "load", "load"
    option :sources, aliases: '-s', type: :array, required: true, default: [DEFAULT_SOURCE_FILE], desc: 'source'
    option :command, type: :string, desc: 'source'
    def load
      options['sources'].each do |source|
        begin
          @core.load(source)
        rescue => e
          raise "error => [#{source}]\n#{e.message}\n#{e.backtrace.join("\n")}"
        end
      end
      @logger.debug(ENV)
      exec(options['command']) if options['command']
    end
  end
end
