# A test framework has to report a test that doesn't pass. Each fixture
# has tests of every outcome; this runs them through Rubytest and checks
# the counts. Each runs in a process of its own.

require 'rbconfig'

checks = {
  'testcase' => "Executed 11 tests with 5 passing, 1 errors, 2 failures, 1 pending, 2 skipped.",
  'spec'     => "Executed 13 tests with 5 passing, 1 errors, 1 failures, 2 pending, 4 skipped.",
  'feature'  => "Executed 18 tests with 11 passing, 1 errors, 1 failures, 4 pending, 1 skipped."
}

failed = false

checks.each do |name, expected|
  script = "require 'rubytest'; require 'cupel/#{name}'; require './test/helper'; " \
           "Test.run!{ |run| run.files << 'test/fixtures/#{name}_outcomes.rb' }"
  output = IO.popen([RbConfig.ruby, '-Ilib', '-e', script], err: [:child, :out], &:read)
  output = output.gsub(/\e\[[0-9;]*m/, '')
  if output.include?(expected) && !$?.success?
    puts "ok      #{name}"
  else
    failed = true
    puts "not ok  #{name}: expected #{expected.inspect} and a failing exit status in\n#{output}"
  end
end

exit 1 if failed
