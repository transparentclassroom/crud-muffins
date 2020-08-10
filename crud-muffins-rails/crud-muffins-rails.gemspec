require_relative 'lib/crud-muffins-rails/version'

Gem::Specification.new do |spec|
  spec.name          = "crud-muffins-rails"
  spec.version       = CrudMuffins::Rails::VERSION
  spec.authors       = ["Andrew Smith"]
  spec.email         = ["andrewsmith@alumni.stanford.edu"]

  spec.summary       = %q{A half-baked solution to standardizing CRUD operations with a frontend client.}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/AndrewSouthpaw/crud-muffins/tree/master/crud-muffins-rails"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/AndrewSouthpaw/crud-muffins"
  spec.metadata["changelog_uri"] = "https://github.com/AndrewSouthpaw/crud-muffins/tree/master/crud-muffins-rails/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '>= 5.0', '< 7.0'
  spec.add_development_dependency 'activemodel', '>= 5.0', '< 7.0'
end
