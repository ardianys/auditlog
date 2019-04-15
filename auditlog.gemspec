$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'auditlog/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'auditlog'
  s.version     = AuditLog::VERSION
  s.licenses    = ['MIT']
  s.authors     = ['Ardian Yuli Setyanto']
  s.email       = ['ardianys@gmail.com']
  s.homepage    = 'http://github.com/ardianys/auditlog'
  s.summary     = 'Log active record changes in file instead in DB'
  s.description = "
    Reference:
    https://github.com/RepairPal/simple_audit_trail
  "

  s.files = Dir['{app,db,lib,config}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '>= 4.0.0'
end
