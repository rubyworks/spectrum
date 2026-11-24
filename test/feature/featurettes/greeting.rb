# Loaded automatically, being in the `featurettes` directory next to
# the features.

module GreetingSteps
  include Cupel::Featurette

  Given "a person named (\\w+)" do |name|
    @name = name
  end

  When "they are greeted" do
    @greeting = greet(@name)
  end

  def greet(name)
    "Hello, #{name}!"
  end
end
