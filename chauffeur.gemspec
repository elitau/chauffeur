# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "chauffeur/version"

Gem::Specification.new do |s|
  s.name        = "chauffeur"
  s.version     = Chauffeur::VERSION
  s.authors     = ["Eduard Litau"]
  s.email       = ["eduard.litau@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Jenkins jobs in ruby, like whenever but with Jenkins CI instead of cron.}
  s.description = %q{Clean ruby syntax for writing and deploying jenkins jobs.}

  s.rubyforge_project = "chauffeur"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency(%q<aaronh-chronic>, [">= 0.3.9"])
  s.add_runtime_dependency(%q<activesupport>, [">= 2.3.4"])
  s.add_development_dependency "rspec", "~> 2.6"
end
