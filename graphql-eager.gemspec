# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/eager/version'

Gem::Specification.new do |spec|
  spec.name          = "graphql-eager"
  spec.version       = GraphQL::Eager::VERSION
  spec.authors       = ["Arzav Jain"]
  spec.email         = ["graphql-eager@googlegroups.com"]

  spec.summary       = <<~SUMMARY
    An extension to the graphql gem to support eager loading.
  SUMMARY
  spec.description   = <<~DESCRIPTION
    graphql-eager is an extension to the graphql gem to solve the N+1 query problem.
    It allows the specification of what needs to be eager loaded in order for each field
    to be computed and then eager-loads only what's necessary given a query.
  DESCRIPTION
  spec.homepage      = "https://github.com/arzavj/graphql-eager"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "graphql", ">= 1.9", "< 2"

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
