# frozen_string_literal: true

require_relative "lib/airbyte/version"

Gem::Specification.new do |spec|
  spec.name = "airbyte"
  spec.version = Airbyte::VERSION
  spec.authors = ["Ameya Bapat"]
  spec.email = ["ameya.bapat@getblueshift.com"]

  spec.summary = "Airbyte API Client "
  spec.description = "It wraps the airbyte Rest API calls"
  spec.homepage = ""
  
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_runtime_dependency "json", "~> 2.3.0"
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "faraday_middleware"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "awesome_print"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
