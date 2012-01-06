# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require "reporter/version"

Gem::Specification.new do |s|
  s.name        = "reporter"
  s.version     = Reporter::VERSION
  s.authors     = ["Krishnaprasad Varma"]
  s.email       = ["krishnaprasadvarma@gmail.com"]
  s.homepage    = "https://github.com/kpvarma/reporter"
  s.summary     = %q{reporter is a gem which can be attached to any model to build custom query on it using joins and selects}
  s.description = %q{It comes with its own helper methods to display the reports. either in the form of an html table, or using google charts, or google chart table apis.}

  s.rubyforge_project = "reporter"

  s.files         = Dir.glob("{bin,lib}/**/*")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_path  = 'lib'

  #s.add_development_dependency "rspec"
  s.add_development_dependency "kaminari"
  s.add_development_dependency "supermodel"
  
end

