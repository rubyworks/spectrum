require_relative 'lib/cupel/version'

Gem::Specification.new do |s|
  s.name        = 'cupel'
  s.version     = Cupel::VERSION
  s.summary     = 'A choice of test structures: test cases, specifications or features'
  s.description = 'Cupel provides the words that organize tests, in three styles, each loaded ' \
                  'on its own: test cases and tests, describe and it, or features and scenarios. ' \
                  'The tests are run by Rubytest, and what they assert is left to an assertion ' \
                  'library such as Assay.'

  s.authors     = ['Thomas Sawyer']
  s.email       = ['transfire@gmail.com']

  s.homepage    = 'https://github.com/rubyworks/cupel'
  s.license     = 'BSD-2-Clause'

  s.metadata    = {
    'source_code_uri' => 'https://github.com/rubyworks/cupel',
    'changelog_uri'   => 'https://github.com/rubyworks/cupel/blob/master/HISTORY.md',
    'bug_tracker_uri' => 'https://github.com/rubyworks/cupel/issues'
  }

  s.required_ruby_version = '>= 2.7'

  s.files       = Dir['lib/**/*.rb', 'LICENSE.txt', 'README.md', 'HISTORY.md']
  s.require_paths = ['lib']

  s.add_dependency 'rubytest', '>= 0.11.1'

  s.add_development_dependency 'rake', '>= 13'
  s.add_development_dependency 'assay', '>= 0.5'
end
