testcase "Cupel::World" do

  test "helpers are available in a test" do
    world_helper.assert == "helped by the world"
  end

  context "and in a context" do
    test "helpers are available" do
      world_helper.assert == "helped by the world"
    end
  end

end
