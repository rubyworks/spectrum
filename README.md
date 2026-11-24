# Cupel

[Source Code](https://github.com/rubyworks/cupel) /
[Report Issue](https://github.com/rubyworks/cupel/issues)

Cupel is a library of test structures: the words that organize tests
into cases, specifications or features. Pick the one you like to write
in; each is loaded on its own.

| Require | Structure |
|---|---|
| `cupel/testcase` | `TestCase "..." do`, `test "..." do`, `setup`, `teardown` |
| `cupel/spec` | `describe "..." do`, `it "..." do`, `before`, `after`, `let` |
| `cupel/feature` | `Feature "..." do`, `Scenario "..." do`, `Given`, `When`, `Then` |

Cupel does two things and leaves the rest to others:

* **Running** is done by [Rubytest](https://github.com/rubyworks/rubytest).
  Every structure builds test objects that Rubytest understands, so its
  command line, report formats and filters work with all of them.
* **Asserting** is left to an assertion library. Cupel is the
  counterpart of [Assay](https://github.com/rubyworks/assay), which
  offers a choice of assertion notations in the same way, but anything
  that raises an assertion Rubytest recognizes will do.

So a project chooses one of each:

```ruby
# test/helper.rb
require 'cupel/spec'        # how tests are organized
require 'assay/ae/should'   # how they assert
```

    $ rubytest -Ilib -r ./test/helper test/*_spec.rb

The examples below use Assay's AE notation.


## Test cases

```ruby
require 'cupel/testcase'

TestCase Array do

  setup do
    @list = [1, 2, 3]
  end

  test "has a size" do
    @list.size.assert == 3
  end

  context "#join" do
    test "joins the elements" do
      @list.join.assert == "123"
    end
  end

end
```

* `TestCase` is also spelled `test_case` or `testcase`, and `test`,
  `context`, `setup`, `teardown` and `skip` may be capitalized.
* Each test runs in an instance of its own, after `setup` and before
  `teardown`. A context inherits its parent's.
* Methods defined in a test case are helpers for its tests.
* A test without a block is reported as still to be done.

A test whose block takes arguments is parameterized, and each `ok`
after it makes a test of it:

```ruby
test "is even" do |x|
  x.assert.even?
end

ok 2
ok 4
```

To skip tests, with a reason:

```ruby
skip "waiting on the new parser" do
  test "parses the new syntax" do
    ...
  end
end
```


## Specifications

```ruby
require 'cupel/spec'

describe Array do

  let(:list) { [1, 2, 3] }

  before :each do
    @calls = 0
  end

  it "has a size" do
    list.size.should == 3
  end

  describe "#join" do
    it "joins the elements" do
      list.join.should == "123"
    end
  end

  it "is something to get to"

end
```

* `describe` is also `context` within a specification, and `it` is
  also `example`.
* `before` and `after` take `:each` (the default) or `:all`, and for
  `:each` may be limited to examples matching a label, pattern or tag:
  `before :each, /database/ do`.
* `let` and `let!` define values, `subject` the subject, and `its` an
  example about a method of the subject.
* `shared_examples_for "..."` defines examples that
  `it_behaves_like "..."` brings in.
* `pending "reason"` inside an example, or an example without a block,
  reports it as still to be done.
* `skip "reason", /pattern/` skips the examples of the context that
  match, and `skip "reason"` all of them. `omit /pattern/` leaves them
  out altogether.

When a specification describes a class, a method the example doesn't
have is sent to a new instance of that class:

```ruby
describe Array do
  it "starts out empty" do
    size.should == 0
  end
end
```


## Features

```ruby
require 'cupel/feature'

Feature "Addition" do
  To "avoid silly mistakes"
  As "a math idiot"
  I  "need to calculate the sum of numbers"

  Scenario "Add two numbers" do
    Given "I have entered 50 into the calculator"
    And   "I have entered 70 into the calculator"
    When  "I press add"
    Then  "the result should be 120 on the screen"
  end

  Given 'I have entered (\d+) into the calculator' do |n|
    @calculator ||= Calculator.new
    @calculator.push n.to_i
  end

  When 'I press add' do
    @result = @calculator.add
  end

  Then 'the result should be (\d+) on the screen' do |n|
    @result.assert == n.to_i
  end
end
```

A scenario lists its steps; the feature defines them. A step is run by
the first definition of its kind whose description matches the whole
step, ignoring case and the amount of whitespace. Text in parentheses
is a regular expression, and what it matches is passed to the block.

* Each step is reported as a test. If a step fails, the ones after it
  in the scenario are not run.
* A step with no definition is reported as still to be done.
* Each scenario runs in a scope of its own.
* `skip "reason"` skips the scenario that follows.

Step definitions can be shared between features by putting them in a
module that includes `Cupel::Featurette`:

```ruby
module CalculatorSteps
  include Cupel::Featurette

  When 'I press add' do
    @result = @calculator.add
  end
end

Feature "Addition" do
  include CalculatorSteps
  ...
end
```

Files in a `featurettes` directory next to a feature are loaded
automatically.


## Helpers for every test

A method defined in `Cupel::World` is available inside every test,
example and step, whichever structure it is written in.

```ruby
module Cupel::World
  def fixture(name)
    File.read("test/fixtures/#{name}")
  end
end
```


## Where it came from

Cupel combines three earlier gems, which it replaces:

| Before | Now |
|---|---|
| gem `citron`, `require 'citron'` | `require 'cupel/testcase'` |
| gem `spectroscope`, `require 'spectroscope'` | `require 'cupel/spec'` |
| gem `lime`, `require 'lime'` | `require 'cupel/feature'` |

The words are the same. What changed is listed in
[HISTORY.md](HISTORY.md); in short, several things that silently did
the wrong thing now don't.

[Lemon](https://github.com/rubyworks/lemon), the strict unit test
framework, is a separate gem and also runs on Rubytest.


## Installation

    $ gem install cupel


## License & Copyright

Copyright (c) 2011 Rubyworks

Cupel is distributed under the terms of the BSD-2-Clause license. See
LICENSE.txt for details.
