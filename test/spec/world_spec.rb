describe "Cupel::World" do

  it "gives its helpers to an example" do
    world_helper.should == "helped by the world"
  end

  def local_helper
    "helped locally"
  end

  it "does not get in the way of a context's own helpers" do
    local_helper.should == "helped locally"
  end

  describe "in a sub-context" do
    it "has both" do
      world_helper.should == "helped by the world"
      local_helper.should == "helped locally"
    end
  end

end

describe "a mistyped method" do

  it "is a NameError, with or without a subject" do
    expect NameError do
      no_such_method_anywhere
    end
  end

  describe Array do
    it "is a NameError when the subject lacks it too" do
      expect NameError do
        no_such_method_anywhere
      end
    end

    it "reaches the subject when the subject has it" do
      size.should == 0
    end
  end

end
