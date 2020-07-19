require_relative 'lib/sideroo/version'

Gem::Specification.new do |spec|
  spec.name          = "sideroo"
  spec.version       = Sideroo::VERSION
  spec.authors       = ["Duong Nguyen"]
  spec.email         = ["ntd251@users.noreply.github.com"]

  spec.summary       = %q{Declarative and auditable object-oriented library for Redis}
  spec.description   = %q{
    Provide a declarative Redis key definition, intuitive key initialization, object-oriented methods for Redis data type, and auditable Redis key management.
  }
  spec.homepage      = "https://github.com/ntd251/sideroo"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ntd251/sideroo"
  spec.metadata["changelog_uri"] = "https://github.com/ntd251/sideroo"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
