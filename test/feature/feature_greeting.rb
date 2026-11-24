Feature "Greeting" do
  To "be polite"
  As "a program"
  I  "greet people by name"

  include GreetingSteps

  Scenario "Greet one person" do
    Given "a person named Ada"
    When  "they are greeted"
    Then  "the greeting is 'Hello, Ada!'"
  end

  Scenario "Whitespace and case in a step don't matter" do
    Given "A   person named Grace"
    When  "they are greeted"
    Then  "the greeting is 'Hello, Grace!'"
    And   "the world helps"
  end

  Then "the greeting is '(.*)'" do |text|
    @greeting.assert == text
  end

  Then "the world helps" do
    world_helper.assert == "helped by the world"
  end
end
