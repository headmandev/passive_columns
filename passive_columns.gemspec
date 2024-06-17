# $:.push File.expand_path("lib", __dir__)
# require "passive_columns/version"
require_relative "lib/passive_columns/version"

Gem::Specification.new do |spec|
  spec.name         = 'passive_columns'
  spec.version      = PassiveColumns::VERSION
  spec.summary      = 'Gem for retrieving columns from a database on demand'
  spec.description  = 'A gem that allows you to exclude some columns from a SELECT query by default and load them only on demand'
  spec.author       = "Dmitry Golovin"
  spec.email        = "headman.dev@gmail.com"
  spec.homepage     = "https://github.com/headmandev/passive_columns"
  spec.license      = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end
  spec.required_ruby_version = ">= 2.7"
  spec.add_dependency "activerecord", ">= 7.1"
  spec.add_dependency "activesupport", ">= 7.1"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop"
end