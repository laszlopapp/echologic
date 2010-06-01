@translation @0.1


Feature: Translation permission

  @ok
  Scenario: Unlogged user unable to translate
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should not see "Please translate this statement in English"
    
  @ok
  Scenario: user without spoken languages unable to translate
    Given I am logged in as "red" with password "true"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should not see "Please translate this statement in English"
    
  @ok
  Scenario: user without mother tongue unable to translate
    Given I am logged in as "yellow" with password "true"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should not see "Please translate this statement in English"
    
  @ok
  Scenario: document translated in current language already exists
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should not see "Please translate this statement in English"
  
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
      And I choose the "Andere Frage?" Question
    Then I should see "Andere Frage?"
    Then I should not see "Please translate this statement in English"
    
  @ok
  Scenario: user has language level smaller than intermediate, thus can not translate
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
    Then I should see "Andere Frage?"
    Then I should not see "Please translate this statement in English"
    
  @ok
  Scenario: luise has enough language level to translate
    Given I am logged in as "luise" with password "luise"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
    Then I should see "Andere Frage?"
    Then I should see "Please translate this statement in English"
    
    
  @ok
  Scenario: luise tries to translate but doesn't fill text
    Given I am logged in as "luise" with password "luise"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I follow "Please translate this statement in English"
      And I fill in the following:
        | question_new_statement_document_title | Another Question? |
      And I press "Save"
    Then I should see "One of the fields is filled incorrectly."
    
  @ok
  Scenario: luise tries to translate but doesn't fill title
    Given I am logged in as "luise" with password "luise"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I follow "Please translate this statement in English"
      And I fill in the following:
        | question_new_statement_document_text | new text in english |
      And I press "Save"
    Then I should see "One of the fields is filled incorrectly."
    
  @ok
  Scenario: luise succeeds in translating a question
    Given I am logged in as "luise" with password "luise"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I follow "Please translate this statement in English"
      And I fill in the following:
        | question_new_statement_document_title | Another Question? |
        | question_new_statement_document_text | new text in english |
      And I press "Save"
    Then I should see "new text in english"
    
  @ok
  Scenario: luise succeeds in translating a proposal
    Given I am logged in as "luise" with password "luise"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I choose the "Vorschlag auf Deutsch" Proposal
      And I follow "Please translate this statement in English"
      And I fill in the following:
        | proposal_new_statement_document_title | Proposal in German |
        | proposal_new_statement_document_text | new text in english |
      And I press "Save"
    Then I should see "new text in english"
    
  @ok
  Scenario: luise succeeds in translating an improvement proposal
    Given I am logged in as "luise" with password "luise"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I choose the "Vorschlag auf Deutsch" Proposal
      And I choose the "Verbesserungsvorschlag auf Deutsch" Improvement Proposal
      And I follow "Please translate this statement in English"
      And I fill in the following:
        | improvement_proposal_new_statement_document_title | Improvement Proposal in German |
        | improvement_proposal_new_statement_document_text | new text in english |
      And I press "Save"
    Then I should see "new text in english"
  
  @ok
  Scenario: illiterate doesn't speak any languages, and sees a warning when he chooses a question which original language is german
    Given I am logged in as "illiterate" with password "illiterate"
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Raindrops keep falling on my head" Question     
    Then I should see "The original statement is in German. Tell us which languages you speak to see content in other languages."
    