@translation @0.1


Feature: Translation permission

  @ok
  Scenario: Unlogged user unable to translate
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Test Question" Question
    Then I should not see "Please translate this statement to ENGLISH"

  @ok
  Scenario: user without spoken languages unable to translate
    Given I am logged in as "red" with password "true"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Test Question" Question
    Then I should not see "Please translate this statement to ENGLISH"

  @ok
  Scenario: user without mother tongue unable to translate
    Given I am logged in as "yellow" with password "true"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Test Question" Question
    Then I should not see "Please translate this statement to ENGLISH"

  @ok
  Scenario: document translated in current language already exists
    Given I am logged in as "user" with password "true"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Test Question" Question
    Then I should not see "Please translate this statement to ENGLISH"

  @ok
  Scenario: joe should see document that only exists in german
    Given I am logged in as "joe" with password "true"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      Then I should see "Andere Frage?"

  @ok
  Scenario: user has language level smaller than intermediate, thus can not translate
    Given I am logged in as "user" with password "true"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
    Then I should see "Andere Frage?"
    Then I should not see "Please translate this statement to ENGLISH"

  @ok
  Scenario: luise has enough language level to translate
    Given I am logged in as "luise" with password "luise"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
    Then I should see "Andere Frage?"
    Then I should see "Please translate this statement to ENGLISH"


  @ok
  Scenario: luise tries to translate but doesn't fill text
    Given I am logged in as "luise" with password "luise"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I follow "Please translate this statement to ENGLISH"
      And I fill in the following:
        | question_new_statement_document_title | Another Question? |
      And I press "Save"
    Then I should see "The field 'Summary' must not be empty."

  @ok
  Scenario: luise tries to translate but doesn't fill title
    Given I am logged in as "luise" with password "luise"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I follow "Please translate this statement to ENGLISH"
      And I fill in the following:
        | question_new_statement_document_text | new statement to ENGLISH |
      And I press "Save"
    Then I should see "The field 'Title' must not be empty."

  @ok
  Scenario: luise succeeds in translating a question
    Given I am logged in as "luise" with password "luise"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I follow "Please translate this statement to ENGLISH"
      And I fill in the following:
        | question_new_statement_document_title | Another Question? |
        | question_new_statement_document_text | new statement to ENGLISH |
      And I press "Save"
    Then I should see "new statement to ENGLISH"

  @ok
  Scenario: luise succeeds in translating a proposal
    Given I am logged in as "luise" with password "luise"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I choose the "Vorschlag auf Deutsch" Proposal
      And I follow "Please translate this statement to ENGLISH"
      And I fill in the following:
        | proposal_new_statement_document_title | Proposal in German |
        | proposal_new_statement_document_text | new statement to ENGLISH |
      And I press "Save"
    Then I should see "new statement to ENGLISH"

  @ok
  Scenario: luise succeeds in translating an improvement
    Given I am logged in as "luise" with password "luise"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
      And I choose the "Vorschlag auf Deutsch" Proposal
      And I choose the "Verbesserungsvorschlag auf Deutsch" Improvement
      And I follow "Please translate this statement to ENGLISH"
      And I fill in the following:
        | improvement_new_statement_document_title | Improvement in German |
        | improvement_new_statement_document_text | new statement to ENGLISH |
      And I press "Save"
    Then I should see "new statement to ENGLISH"

  @ok
  Scenario: illiterate doesn't speak any languages, and sees a warning when he chooses a question which original language is german
    Given I am logged in as "illiterate" with password "illiterate"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Andere Frage?" Question
    Then I should see "Set your language skills to see content only in languages you speak"

  @ok
  Scenario: illiterate doesn't speak any languages, and  does not see a warning when he chooses a question which original language is german with the application in german
    Given I am logged in as "illiterate" with password "illiterate"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      And I choose the "Raindrops keep falling on my head" Question
      And I change the application language to "de"
    Then I should not see "Die originale Aussage ist auf DEUTSCH. Definieren Sie Ihre Sprachkenntnisse, um weitere Inhalte zu sehen."
      And I change the application language to "en"