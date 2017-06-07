module Envault
  module Cryptor
    class Simple
      def initialize(profile)
        passphrase = profile[:passphrase] || ''
        sign_passphrase = profile[:sign_passphrase]
        salt = profile[:salt] || ''

        key = ActiveSupport::KeyGenerator.new(passphrase).generate_key(salt, 32)
        signature_key = ActiveSupport::KeyGenerator.new(sign_passphrase).generate_key(salt, 32) if sign_passphrase

        if signature_key
          @cryptor = ActiveSupport::MessageEncryptor.new(key, signature_key, cipher: DEFAULT_CIPHER, digest: DEFAULT_DIGEST)
        else
          @cryptor = ActiveSupport::MessageEncryptor.new(key, cipher: DEFAULT_CIPHER, digest: DEFAULT_DIGEST)
        end
      end

      def encrypt(value)
        @cryptor.encrypt_and_sign(value)
      end

      def decrypt(value)
        @cryptor.decrypt_and_verify(value)
      end
    end
  end
end
