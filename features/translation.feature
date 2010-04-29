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
  
  @ok
  Scenario: joe should see document that only exists in german
    Given I am logged in as "joe" with password "true"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      Then I should see "Andere Frage?"
      
  @ok
  Scenario: ben doesn't have current language as mother tongue
    Given I am logged in as "ben" with password "benrocks"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should see "Andere Frage?"
    Then I should not see "Please translate this text in English"
    
  @ok
  Scenario: user has language level smaller than intermediate, thus can not translate
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should see "Andere Frage?"
    Then I should not see "Please translate this text in English"
    
  @ok
  Scenario: luise has enough language level to translate
    Given I am logged in as "luise" with password "luise"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should see "Andere Frage?"
    Then I should see "Please translate this text in English"