@translation @0.1


Feature: Translation permission

  @ok
  Scenario: Unlogged user unable to translate
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should not see "Please translate this text in English"
    
  @ok
  Scenario: user without spoken languages unable to translate
    Given I am logged in as "red" with password "true"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should not see "Please translate this text in English"
    
  @ok
  Scenario: user without mother tongue unable to translate
    Given I am logged in as "yellow" with password "true"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should not see "Please translate this text in English"
    
  @ok
  Scenario: document translated in current language already exists
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should not see "Please translate this text in English"