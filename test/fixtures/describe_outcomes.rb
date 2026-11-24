# One example of each outcome, for test/outcomes.rb to count.

order = []

describe "outcomes" do

  before(:all)  { order << :before_all }
  before(:each) { order << :outer_before }
  after(:each)  { order << :outer_after }

  it "passes" do
    1.should == 1
  end

  it "fails" do
    1.should == 2
  end

  it "errors" do
    raise ArgumentError, "oops"
  end

  it "is pending" do
    pending "later"
  end

  it "is not written yet"

  it "is slow and skipped" do
    raise "never run"
  end

  it "is omitted entirely" do
    raise "never run"
  end

  describe "a context within" do
    # Defined before the outer hooks below, and still subject to them.
    it "is slow too, in a sub-context" do
      raise "never run"
    end

    before(:each) { order << :inner_before }
    after(:each)  { order << :inner_after }

    it "runs hooks from the outside in, and back out" do
      order.last(2).should == [:outer_before, :inner_before]
    end

    it "ran the after hooks of the example before" do
      order.last(4).should == [:inner_after, :outer_after, :outer_before, :inner_before]
    end
  end

  it "ran before-all once" do
    order.count(:before_all).should == 1
  end

  it "ran the after hook for the failure and the error" do
    order.count(:outer_after).should == order.count(:outer_before) - 1
  end

  skip "too slow", /slow/
  omit /omitted/

end

describe "a context skipped whole" do
  skip "not ready"

  it "is skipped" do
    raise "never run"
  end

  describe "and its sub-contexts" do
    it "is skipped as well" do
      raise "never run"
    end
  end
end
