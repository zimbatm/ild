require File.expand_path('../lib/ild/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'ild'
  s.version = Ild::VERSION
  s.summary = 'Faster than build'
  s.description = 'An opinionated tool to build projects'

  s.author = 'zimbatm'
  s.email = 'zimbatm@zimbatm.com'
  s.homepage = 'https://github.com/zimbatm/ild'
  s.license = 'MIT'

  s.files = %w[README.md bin/ild lib/ild.rb] +
    Dir['lib/ild/**/*.rb', 'data/**/*']

  s.executable = 'ild'

  s.add_dependency 'excon'
  s.add_dependency 'json'
  s.add_dependency 'thor'
end
