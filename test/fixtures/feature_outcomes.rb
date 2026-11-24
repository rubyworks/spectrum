# Scenarios of each outcome, for test/outcomes.rb to count.

Feature "Outcomes" do
  To "know that failures are reported"
  As "the author of a test framework"
  I  "need scenarios that don't pass"

  Scenario "passes" do
    Given "a count of 1"
    When  "I add 2"
    Then  "the count is 3"
  end

  Scenario "starts from a clean slate" do
    Then "the count is unset"
  end

  Scenario "fails at the end" do
    Given "a count of 1"
    When  "I add 2"
    Then  "the count is 4"
  end

  Scenario "errors in the middle" do
    Given "a count of 1"
    When  "I divide by 0"
    Then  "the count is 1"
  end

  Scenario "has a step with no definition" do
    Given "a count of 1"
    When  "I do something nobody defined"
    Then  "the count is 1"
  end

  skip "not today"
  Scenario "is skipped" do
    Given "a count of 1"
  end

  Scenario "is not skipped, since skip applies to one scenario" do
    Given "a count of 5"
    And   "a count of 6"
    Then  "the count is 6"
  end

  Scenario "only matches whole descriptions" do
    Given "a count of 1 or so"
  end

  Given 'a count of (\d+)' do |n|
    @count = n.to_i
  end

  When 'I add (\d+)' do |n|
    @count += n.to_i
  end

  When 'I divide by (\d+)' do |n|
    @count /= n.to_i
  end

  Then 'the count is (\d+)' do |n|
    @count.assert == n.to_i
  end

  Then 'the count is unset' do
    @count.assert == nil
  end
end
