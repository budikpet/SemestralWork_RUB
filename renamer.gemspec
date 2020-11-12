# frozen_string_literal: true

require File.expand_path('lib/renamer/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'renamer'
  s.version     = Renamer::VERSION
  # s.homepage    = '{origin-repo-uri}'
  s.license     = 'MIT'
  s.author      = 'Petr Budík'
  s.email       = 'budikpet@fit.cvut.cz'

  s.summary     = 'Batch-rename of multiple files.'
  s.description = 'A Thor powered CLI tool for batch rename of multiple files.
    Inspired by built-in batch rename tool of MacOS Finder.'

  s.files       = Dir['bin/*', 'lib/**/*', '*.gemspec', 'LICENSE*', 'README*']
  s.executables = Dir['bin/*'].map { |f| File.basename(f) }

  s.required_ruby_version = '>= 2.4'

  s.add_development_dependency 'bundler', '>= 1.0', '< 3'
end
