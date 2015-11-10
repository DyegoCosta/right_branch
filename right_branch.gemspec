require './lib/right_branch/version'

Gem::Specification.new do |gem|
  gem.name        = 'right_branch'
  gem.version     = RightBranch::VERSION

  gem.authors     = ['Dyego Costa']
  gem.email       = 'dyego@dyegocosta.com'
  gem.summary     = 'Change GitHub Pull Request target branch'
  gem.description = 'If you submit a Pull Request to a wrong branch on GitHub you can use this gem to change it'

  gem.homepage    = 'https://github.com/dyegocosta/right_branch'
  gem.license     = 'MIT'

  gem.executables = %x{ git ls-files }.split("\n").select { |d| d =~ /^bin\// }.map { |d| d.gsub(/^bin\//, "") }
  gem.files       = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(License|README|bin/|data/|ext/|lib/|spec/|test/)} }

  gem.add_dependency 'octokit'
  gem.add_dependency 'highline'

  gem.add_development_dependency 'rspec', '~> 3.1', '>= 3.1.0'
end
