
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "batch_queue/version"

Gem::Specification.new do |spec|
  spec.name          = "batch_queue"
  spec.version       = BatchQueue::VERSION
  spec.authors       = ["Felix Livni"]
  spec.email         = ["flivni@gmail.com"]

  spec.summary       = 'An in-memory queue that takes data and allows you to process it, in batches, on a background thread.'
  # spec.description   = ''
  spec.homepage      = 'https://github.com/flivni/batch_queue'
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", '~> 1.4'
end
