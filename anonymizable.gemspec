# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "anonymizable/version"

Gem::Specification.new do |s|
  s.name          = "anonymizable"
  s.description   = "Delete data without deleting it"
  s.summary       = "Anonymize columns in ActiveRecord models"
  s.homepage      = "https://github.com/silvercar/anonymizable"
  s.authors       = ["Mike Bradford"]
  s.email         = ["mike.bradford@silvercar.com"]
  s.version       = Anonymizable::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.add_dependency "activerecord", "~> 3.2"

  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "database_cleaner", "~> 1.0"
  s.add_development_dependency "bcrypt", "~> 3.1"
end
