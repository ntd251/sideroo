require_relative 'lib/sider/version'

Gem::Specification.new do |spec|
  spec.name          = "sider"
  spec.version       = Sider::VERSION
  spec.authors       = ["Duong Nguyen"]
  spec.email         = ["ntd251@users.noreply.github.com"]

  spec.summary       = %q{Provide an object oriented abstraction for Redis}
  spec.description   = %q{Provide an object oriented abstraction for Redis}
  spec.homepage      = "https://github.com/ntd251/sider"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ntd251/sider"
  spec.metadata["changelog_uri"] = "https://github.com/ntd251/sider"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
