lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'human_query_parser/version'

Gem::Specification.new do |spec|
  spec.name          = 'human_query_parser'
  spec.version       = HumanQueryParser::VERSION
  spec.authors       = ['PatientsLikeMe']
  spec.email         = ['engineers@patientslikeme.com']
  spec.homepage      = 'https://www.patientslikeme.com'

  spec.summary       = 'A tool for taking search queries of the form most users will expect, and producing ElasticSearch queries that do what most users would expect.'
  spec.description   = 'A tool for taking search queries of the form most users will expect, and producing ElasticSearch queries that do what most users would expect.'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://gemfury.io'
  end

  spec.add_runtime_dependency 'parslet', '~> 1.8'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'pry'
end
