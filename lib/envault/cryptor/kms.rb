module Envault
  module Cryptor
    class Kms
      def initialize(profile)
        require 'aws-sdk'
        options = {}
        options[:region] = profile[:region] if profile[:region]
        options[:access_key_id] = profile[:aws_access_key_id] if profile[:aws_access_key_id]
        options[:secret_access_key] = profile[:aws_secret_access_key] if profile[:aws_secret_access_key]
        @client = Aws::KMS::Client.new(options)
        @key_id = profile[:key_id]
      end

      def encrypt(value)
        resp = @client.encrypt(key_id: @key_id, plaintext: value)
        Base64.strict_encode64(resp.ciphertext_blob)
      end

      def decrypt(value)
        resp = @client.decrypt(ciphertext_blob: Base64.strict_decode64(value))
        resp.plaintext
      end
    end
  end
end
