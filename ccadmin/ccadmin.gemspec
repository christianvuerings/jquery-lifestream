$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'ccadmin/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'ccadmin'
  s.version     = Ccadmin::VERSION
  s.authors     = ['UC Berkeley']
  s.email       = ['calcentral@berkeley.edu']
  s.homepage    = 'https://calcentral.berkeley.edu'
  s.summary     = 'rails_admin for CalCentral'
  s.description = 'rails_admin for CalCentral'
  s.license     = 'ECL-2.0'

  s.files = Dir['{config,lib}/**/*']

  s.add_dependency 'rails', '~> 4.1.6'
  s.add_dependency 'rails_admin', '0.6.5'
  s.add_dependency 'bootstrap-sass', '~> 3.2.0.2'

end
