$:.push File.expand_path("lib", __dir__)
require "passive_columns/version"

Gem::Specification.new do |gem|
  gem.name         = 'passive_columns'
  gem.version      = PassiveColumns::VERSION
  gem.summary      = 'Gem for retrieving columns from a database on demand'
  gem.description  = 'A gem that allows you to exclude some columns from a SELECT query by default and load them only on demand'
  gem.author       = "Dmitry Golovin"
  gem.email        = "headman.dev@gmail.com"
  gem.homepage     = "https://github.com/headmandev/passive_columns"
  gem.license      = "MIT"

  gem.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  gem.required_ruby_version = ">= 3.1"
  gem.add_dependency "activerecord", ">= 7.1"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rspec-rails"
  gem.add_development_dependency "rubocop", "0.64.0"
end