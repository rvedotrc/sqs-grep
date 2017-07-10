lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqs-grep/version'

Gem::Specification.new do |s|
  s.name        = 'sqs-grep'
  s.version     = SqsGrep::VERSION
  s.licenses    = [ 'Apache-2.0' ]
  s.date        = '2017-07-10'
  s.summary     = 'Find messages on an SQS queue by regular expression, and optionally delete them'
  s.description = '
    sqs-grep iterates through each message on the given SQS queue, testing its
    body against the given regular expression, displaying matching messages to
    standard output.

    Options are available to control match inversion, json output, deletion of
    matching messages, match limits, and timeouts.

    Respects $https_proxy.
  '
  s.homepage    = 'https://github.com/rvedotrc/sqs-grep'
  s.authors     = ['Rachel Evans']
  s.email       = 'sqs-grep-git@rve.org.uk'

  s.executables = %w[
sqs-grep
  ]

  s.files       = %w[
lib/sqs-grep.rb
lib/sqs-grep/client.rb
lib/sqs-grep/config.rb
lib/sqs-grep/runner.rb
lib/sqs-grep/version.rb
  ] + s.executables.map {|s| "bin/"+s}

  s.require_paths = ["lib"]

  s.add_dependency 'aws-sdk', "~> 2.0"
end
