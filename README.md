# envault [![Build Status](https://secure.travis-ci.org/toyama0919/envault.png?branch=master)](http://travis-ci.org/toyama0919/envault)

Encrypt secret information environment variables by yaml.

## Settings(Environment Variables)
```
export ENVAULT_PASSPHRASE=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export ENVAULT_SIGN_PASSPHRASE=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export ENVAULT_SALT=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

## Settings(yaml file)
```
development:
  passphrase: ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
  sign_passphrase: ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
  salt: ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
  prefix: ENVAULT_

staging:
  passphrase: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  sign_passphrase: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  salt: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  prefix: ENVAULT_

production:
  passphrase: YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
  sign_passphrase: YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
  salt: YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
  prefix: ENVAULT_
```

## Encrypt and Decrypt
```bash
$ cat .env
USERNAME_A: hogehoge
USERNAME_B: fugafuga
USERNAME_C: mogomogo
PASSWORD_A: hogehoge
PASSWORD_B: fugafuga
PASSWORD_C: mogomogo
API_KEY_A: hogehoge
API_KEY_B: fugafuga
API_KEY_C: mogomogo

## encrypt file
$ envault -e -s .env -c envault.yml --profile staging -k '^PASSWORD_.*' '^API_KEY_.*' > .env.encrypt
$ cat .env.encrypt
USERNAME_A: "hogehoge"
USERNAME_B: "fugafuga"
USERNAME_C: "mogomogo"
ENVAULT_PASSWORD_A: "VmI4TkcwYXFRdnp3cTNINFo5NHZNWWtUakd4WE9iWDhJdFIzVnQydXlMaz0tLU5CS2JONW1FalorMGxsOGxUYmpXUFE9PQ==--3e301c251f5a7cf0e6280daa3bc14cc04c2cbff492758028c9e5fd6ddc72660e"
ENVAULT_PASSWORD_B: "QzI1eFZnampSZkk3QWxEYkZjemNlMVpmWWVEVFluZjhJV01zS3JKNUlvST0tLUNvWDdNWVFGMUMwVGEvaTNFMkJVU2c9PQ==--d58c39f5e71b382f2d2778e8c02c58339ed330e0dc31067ed6544fcb94397700"
ENVAULT_PASSWORD_C: "eGo0S3pLRWV0OFRrdVRzTmwvZlR3VkN6a2xjeHpvcHV0ZlZMenNOUm1Wbz0tLS80WjFuRzQrQ29uSU5SbDBSOGUyRlE9PQ==--7c2342c9533b70af50be5cf1dd12aa66f595263ea4c8aa347b185a7a8e57fb3c"
ENVAULT_API_KEY_A: "QThLSGF4VXNST3ZXL0VTVURzMlQ3aUE2aXppTlc5aUxUWk9Xa0hXS25NYz0tLTAxWlI0OU0zdnZXUG1MdmtYY2FZK0E9PQ==--fff50bafac593d6c50da369f1e040e0f6db8623299078ccda029bbeed12a93c7"
ENVAULT_API_KEY_B: "cWdFS21HdnArNlBzcFhremhFNTJzdzhtYkNwWUIrb2dzekFsbzZxQjRsQT0tLWZUZTdpYW1Bc2xqRXcvMjB4eDRNc1E9PQ==--edb6d0bace9f1cd4c9eeef0a9289d43fd6724625e601aa46e9ebb12f6405efb6"
ENVAULT_API_KEY_C: "YllDcDhYUTJGZWhTRjBaQTU4L3RlZitzYVN3OTV6OXhSbkZHbFBWaWF3cz0tLVo1MGFZVkNWQ3g2UXdwRlBFaW43MWc9PQ==--fd0642530754f235856f9ebba252bb34156666498433e05c2ce29573aad6ec69"

## decrypt file
$ envault -d -s .env.encrypt -c envault.yml --profile staging
USERNAME_A: "hogehoge"
USERNAME_B: "fugafuga"
USERNAME_C: "mogomogo"
PASSWORD_A: "hogehoge"
PASSWORD_B: "fugafuga"
PASSWORD_C: "mogomogo"
API_KEY_A: "hogehoge"
API_KEY_B: "fugafuga"
API_KEY_C: "mogomogo"

## if use other profile, Error
$ envault -d -s .env.encrypt -c envault.yml --profile production                                                                                            1 ↵
/Users/toyama-h/.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/activesupport-4.2.5/lib/active_support/message_verifier.rb:49:in `verify': ActiveSupport::MessageVerifier::InvalidSignature (ActiveSupport::MessageVerifier::InvalidSignature)
        from /Users/toyama-h/.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/activesupport-4.2.5/lib/active_support/message_encryptor.rb:64:in `decrypt_and_verify'
        from /Users/toyama-h/Dropbox/github/envault/lib/envault/core.rb:51:in `block in decrypt_process'
        from /Users/toyama-h/Dropbox/github/envault/lib/envault/core.rb:49:in `each'
        from /Users/toyama-h/Dropbox/github/envault/lib/envault/core.rb:49:in `map'
        from /Users/toyama-h/Dropbox/github/envault/lib/envault/core.rb:49:in `decrypt_process'
        from /Users/toyama-h/Dropbox/github/envault/lib/envault/core.rb:44:in `decrypt_yaml'
        from /Users/toyama-h/Dropbox/github/envault/lib/envault/cli.rb:74:in `block in decrypt_file'
        from /Users/toyama-h/Dropbox/github/envault/lib/envault/cli.rb:73:in `each'
        from /Users/toyama-h/Dropbox/github/envault/lib/envault/cli.rb:73:in `decrypt_file'
        from /Users/toyama-h/.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/thor-0.19.1/lib/thor/command.rb:27:in `run'
        from /Users/toyama-h/.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/thor-0.19.1/lib/thor/invocation.rb:126:in `invoke_command'
        from /Users/toyama-h/.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/thor-0.19.1/lib/thor.rb:359:in `dispatch'
        from /Users/toyama-h/.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/thor-0.19.1/lib/thor/base.rb:440:in `start'
        from /Users/toyama-h/Dropbox/github/envault/bin/envault:6:in `<top (required)>'
        from /Users/toyama-h/bin/envault:17:in `load'
        from /Users/toyama-h/bin/envault:17:in `<main>'
```

## reencrypt(config)
```bash
$ cat .envault.test
old_staging:
  passphrase: ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
  sign_passphrase: ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
  salt: ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
  prefix: OLD_ENVAULT_

staging:
  passphrase: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  sign_passphrase: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  salt: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  prefix: ENVAULT_

$ cat .env.encrypt
OLD_ENVAULT_A: "aaaaaaaaaaaaaa"
OLD_ENVAULT_B: "bbbbbbbbbbbbbbb"
C: "hoge"

$ envault reencrypt_file -s .env.encrypt -c ~/.envault --from_profile old_staging --to_profile staging --overwrite

$ cat .env.encrypt
ENVAULT_A: "ccccccccccccccc"
ENVAULT_B: "ddddddddddddddd"
C: "hoge"

```

## Load AND command(Environment Variables)
```bash
$ envault load -s .env.encrypt --command 'echo $PASSWORD_A'
hogehoge
```

## Load Application(Environment Variables)
```bash
require 'envault'
Envault.load('.env.encrypt')
p ENV['PASSWORD_A']
#=> hogehoge
```

## Load Application(Profile)
```bash
require 'envault'
Envault.load_with_profile('.env.encrypt', config: '.envault', profile: 'staging')
p ENV['PASSWORD_B']
#=> fugafuga
```

## Installation

Add this line to your application's Gemfile:

    gem 'envault'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install envault

## Synopsis

    $ envault

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Information

* [Homepage](https://github.com/toyama0919/envault)
* [Issues](https://github.com/toyama0919/envault/issues)
* [Documentation](http://rubydoc.info/gems/envault/frames)
* [Email](mailto:toyama0919@gmail.com)

## Copyright

Copyright (c) 2016 toyama0919

See [LICENSE.txt](../LICENSE.txt) for details.
