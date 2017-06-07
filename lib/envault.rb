require 'envault/version'
require 'envault/constants'
require 'envault/core'
require 'envault/cli'
require 'envault/environment'
require 'envault/formatter'
require 'envault/cryptor/kms'
require 'envault/cryptor/simple'

module Envault
  def self.load(*source_files)
    source_files = ['.env'] if source_files.empty?
    params = ['load', '--sources', source_files]
    Envault::CLI.start(params)
  end

  def self.load_with_profile(*source_files, config:, profile:)
    source_files = ['.env'] if source_files.empty?
    params = ['load', '--sources', source_files]
    params.concat(['-c', config]) if config
    params.concat(['--profile', profile]) if profile
    Envault::CLI.start(params)
  end
end
