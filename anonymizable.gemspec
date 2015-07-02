# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "anonymizable/version"

Gem::Specification.new do |s|
  s.name          = "anonymizable"
  s.description   = "Delete data without deleting it"
  s.summary       = "Anonymize columns in ActiveRecord models"
  s.homepage      = "https://github.com/47primes/anonymizable"
  s.authors       = ["Mike Bradford"]
  s.email         = ["mbradford@47primes.com"]
  s.version       = Anonymizable::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = Dir.glob("spec/**/*.rb")
  s.require_paths = ["lib"]
  s.executables   << 'cc_processor'

  s.add_dependency "activerecord", ">= 3.2", "< 5.0"

  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "database_cleaner", "~> 1.0"
  s.add_development_dependency "factory_girl", "~> 4.5"
  s.add_development_dependency "pry", "~> 0.10"
  s.add_development_dependency "codeclimate-test-reporter"
end
