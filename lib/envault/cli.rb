require 'thor'
require 'erb'
require 'yaml'

module Envault
  class CLI < Thor
    map '-e' => :encrypt_file
    map '-d' => :decrypt_file
    map '-r' => :reencrypt_file
    map '-l' => :load

    class_option :config, aliases: '-c', type: :string ,desc: 'config'
    class_option :profile, aliases: '-p', type: :string, default: 'default',desc: 'profile'
    class_option :debug, aliases: '--debug', type: :boolean, default: false, desc: 'debug'
    class_option :prefix, type: :string, default: nil, desc: 'prefix'
    def initialize(args = [], options = {}, config = {})
      super(args, options, config)
      @class_options = config[:shell].base.options
      current_command = config[:current_command].name
      unless SKIP_INITIALIZE_COMMANDS.include?(current_command)
        @core = Core.new(
          config: @class_options[:config],
          profile: @class_options[:profile],
          prefix: @class_options[:prefix],
          debug: @class_options[:debug]
        )
        @logger = @core.logger
      end
    end

    desc "encrypt", "encrypt string. exp: envault encrypt -s hoge"
    option :source, aliases: '-s', type: :string, required: true, desc: 'source', banner: 'source'
    def encrypt
      puts @core.cryptor.encrypt(options[:source])
    end

    desc "decrypt", "decrypt string. exp: envault decrypt -s hoge"
    option :source, aliases: '-s', type: :string, required: true, desc: 'source'
    def decrypt
      puts @core.cryptor.decrypt(options[:source])
    end

    desc "-r", "reencrypt file. exp: envault -r -s .env.encrypt -c ~/.envault --from_profile staging --to_profile production"
    option :source, aliases: '-s', type: :string, required: true, desc: 'source'
    option :from_profile, type: :string, required: true, desc: 'from_profile'
    option :to_profile, type: :string, required: true, desc: 'to_profile'
    option :overwrite, type: :boolean, default: false, desc: 'overwrite'
    def reencrypt_file
      yaml = YAML.load_file(options[:source])
      from = Core.new(
        config: @class_options[:config],
        profile: options[:from_profile],
        prefix: @class_options[:prefix],
        debug: @class_options[:debug]
      )
      cipher_keys = from.get_cipher_keys(yaml).map{ |cipher_key| cipher_key.gsub(/^#{from.prefix}/, '') }
      decrypted = from.decrypt_yaml(options[:source])
      to = Core.new(
        config: @class_options[:config],
        profile: options[:to_profile],
        prefix: @class_options[:prefix],
        debug: @class_options[:debug]
      )
      output = to.encrypt_process(decrypted, cipher_keys)
      if options[:overwrite]
        Formatter.write_escape_yaml(options[:source], output)
      else
        puts Formatter.escape_yaml(output)
      end
    end

    desc "-e", "encrypt file. exp. envault -e -s .env -k '^PASSWORD_.*' '^API_KEY_.*'"
    option :source, aliases: '-s', type: :array, required: true, desc: 'secret'
    option :keys, aliases: '-k', type: :array, required: false, desc: 'keys'
    option :plain_text, aliases: '-t', type: :array, default: [], required: false, desc: 'plain'
    option :output, aliases: '-o', type: :string, default: nil, desc: 'output'
    def encrypt_file
      result = {}
      options[:plain_text].each do |plain_text_path|
        result = result.merge(YAML.load(ERB.new(File.read(plain_text_path)).result))
      end
      options[:source].each do |secret_yaml_path|
        result = result.merge(@core.encrypt_yaml(secret_yaml_path, options[:keys]))
      end
      if options[:output]
        Formatter.write_escape_yaml(options[:output], result)
      else
        puts Formatter.escape_yaml(result)
      end
    end

    desc "-d", "decrypt file. exp: envault -d -s .env"
    option :source, aliases: '-s', type: :array, required: true, desc: 'source'
    option :plain_text, aliases: '-t', type: :array, default: [], required: false, desc: 'plain_text'
    option :output, aliases: '-o', type: :string, default: nil, desc: 'output'
    def decrypt_file
      result = {}
      options[:plain_text].each do |plain_text_path|
        result = result.merge(YAML.load(ERB.new(File.read(plain_text_path)).result))
      end
      options[:source].each do |encrypt_yaml_path|
        result = result.merge(@core.decrypt_yaml(encrypt_yaml_path))
      end
      if options[:output]
        Formatter.write_escape_yaml(options[:output], result)
      else
        puts Formatter.escape_yaml(result)
      end
    end

    desc "-l", "load environment. exp: envault -l -s .env --command 'echo $myhostname'"
    option :sources, aliases: '-s', type: :array, required: true, default: [DEFAULT_SOURCE_FILE], desc: 'source'
    option :command, type: :string, desc: 'source'
    def load
      options[:sources].each do |source|
        begin
          @core.load(source)
        rescue => e
          raise "error => [#{source}]\n#{e.message}\n#{e.backtrace.join("\n")}"
        end
      end
      @logger.debug(ENV)
      exec(options[:command]) if options[:command]
    end
  end
end
