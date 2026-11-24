describe "sibling contexts" do

  describe "the first" do
    before(:each){ @a = 1 }

    it "has its own hook" do
      @a.should == 1
    end
  end

  describe "the second" do
    it "does not get the first one's hook" do
      @a.should == nil
    end
  end

end

describe "its" do
  subject { [[1,2,3]] }

  its(:size){ should == 1 }

  its("first.size"){ should == 3 }
end

describe "an example knows where it was defined" do
  example = it "is here", :fast do
    example.source_location.last.should == 28
    File.basename(example.source_location.first).should == "context_spec.rb"
  end

  it "has tags" do
    example.tags.should == [:fast]
    example.assert.match?(:fast)
    example.assert.match?(/here/)
    example.refute.match?(:slow)
  end
end
