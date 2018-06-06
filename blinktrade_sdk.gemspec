# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blinktrade_sdk/version'

Gem::Specification.new do |spec|
  spec.name          = "blinktrade_sdk"
  spec.version       = BlinktradeSdk::VERSION
  spec.authors       = ["Ricardo Malafaia"]
  spec.email         = ["ricardo.malafaia1994@gmail.com"]

  spec.summary       = %q{This gem is a SDK to blinktrade API.}
  spec.description   = %q{With this gem you will be able to make requests to blinktrade API and trade with your own account.}
  spec.homepage      = "https://github.com/maurcarvalho/blinktrade-ruby-sdk"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://github.com/rbm4/blinktrade-ruby"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  puts spec.files
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "sinatra"
  spec.add_dependency "faye-websocket"
end
