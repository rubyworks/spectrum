testcase "each test has an instance of its own" do

  test "sets an instance variable" do
    @x = 1
  end

  test "does not see it" do
    @x.assert == nil
  end

end

testcase "tests keep their place" do

  t = test "knows where it was defined", :fast do
    assert true
  end

  test "has a source location" do
    file, line = t.source_location
    File.basename(file).assert == "case_isolation.rb"
    line.assert == 15
  end

  test "has tags" do
    t.tags.assert == [:fast]
    t.assert.match?(:fast)
    t.refute.match?(:slow)
  end

  test "a parameterized test is labelled with its arguments" do |a, b|
    (a + b).assert == 3
  end

  made = ok 1, 2

  test "labels it" do
    made.to_s.assert == "a parameterized test is labelled with its arguments (1, 2)"
  end

end
