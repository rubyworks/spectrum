require 'rubygems/package_task'

gemspec = Gem::Specification.load('spectrum.gemspec')

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

# Each structure is tested in itself, in a process of its own.
SETS = {
  'testcase' => 'test/testcase/case_*.rb',
  'describe' => 'test/spec/*_spec.rb',
  'feature'  => 'test/feature/feature_*.rb'
}

desc "Run the tests of each structure"
task :test do
  SETS.each do |name, files|
    sh "bundle exec rubytest -Ilib -r spectrum/#{name} -r ./test/helper #{files}"
  end
end

desc "Check that tests which don't pass are reported so"
task :outcomes do
  sh 'bundle exec ruby -Ilib test/outcomes.rb'
end

task :default => [:test, :outcomes]
