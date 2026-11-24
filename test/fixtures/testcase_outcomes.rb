# One test of each outcome, for test/outcomes.rb to count.

log = []

TestCase "outcomes" do

  setup do
    @fresh = @fresh.nil?
    log << :setup
  end

  teardown do
    log << :teardown
  end

  test "passes" do
    1.assert == 1
  end

  test "fails" do
    1.assert == 2
  end

  test "errors" do
    raise ArgumentError, "oops"
  end

  test "is not written yet"

  skip "not today" do
    test "is skipped" do
      raise "never run"
    end
  end

  test "is back to normal after a skip block" do
    assert true
  end

  test "starts from a fresh instance" do
    @fresh.assert == true
  end

  test "ran teardown after the failure and the error" do
    log.count(:teardown).assert == log.count(:setup) - 1
  end

  context "a context" do
    test "passes in a context" do
      assert true
    end

    test "fails in a context" do
      assert false
    end
  end

  skip "the rest"

  test "is skipped too" do
    raise "never run"
  end

end
