# HISTORY

## Unreleased

Cupel brings three test frameworks together as one library of test
structures: Citron (test cases), Spectroscope (specifications) and Lime
(features). Each is loaded on its own, and all run on Rubytest. Cupel
needs Ruby 2.7 or newer.

Changes from the separate gems:

* `require 'cupel/testcase'` in place of `citron`, `cupel/spec` in place
  of `spectroscope`, `cupel/feature` in place of `lime`. The classes are
  `Cupel::TestCase`, `Cupel::Spec::Context` and `Example`, and
  `Cupel::Feature`; a featurette includes `Cupel::Featurette`.
* `Cupel::World` is one module for all three. A method defined in it is
  available inside every test, example and step.
* No assertion library is required or assumed.

Test cases:

* Each test runs in an instance of its own. Before, the tests of a case
  shared one, and with it their instance variables.
* Teardown runs when a test fails.
* A test without a block is reported as still to be done.
* A parameterized test made with `ok` has its arguments in its label.
* `skip` with a block restores the earlier setting when the block ends.

Specifications:

* Before and after hooks apply to the contexts within a context wherever
  they are written, not only to those defined after them. After hooks
  run when an example fails, innermost context first.
* Fix `skip`, which raised a NameError. It takes a reason and then
  labels, patterns or tags to match, or a block; with neither it skips
  the whole context. `omit` takes the same criteria.
* Fix a context's hooks leaking into its sibling contexts.
* Fix `its` with a chain of methods, such as `its("first.size")`.
* A mistyped method inside an example is a NameError, rather than being
  sent to the subject or reported as a missing `described_class`.
* Examples run in a plain object instead of a Module.

Features:

* A step without a definition is reported as still to be done. Before,
  it passed.
* When a step fails, the steps after it in the scenario are not run.
* A step definition has to match the whole of a step's description,
  and only the first definition that matches is run. Before, every
  definition that matched any part of it ran.
* Add `And`, for a further step of the same type as the one before.
