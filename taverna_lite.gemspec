$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "taverna_lite/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "taverna_lite"
  s.version     = TavernaLite::VERSION
  s.authors     = ["Abraham Nieva de la Hidalga"]
  s.email       = ["a.nieva@cs.cardiff.ac.uk"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of TavernaLite."
  s.description = "TODO: Description of TavernaLite."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.14"

  # T2flow gem to parse and read workflows
  s.add_dependency 'taverna-t2flow', "~> 0.4.3"

  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
