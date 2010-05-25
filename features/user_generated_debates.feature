Feature: User Generated Debates

  @ok
  Scenario: Unlogged user unable to create New Debate
    When I am on the Discuss Index
    Then I should not see "Open a new Debate"
    
  @ok
  Scenario: user tries to create Debate without content
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
      And I follow "Open a New Debate"
      And I press "Save"
    Then I should see "Your input for 'Statement' must be in a valid format."
  
  @ok
  Scenario: user tries to create Debate without text
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
      And I follow "Open a New Debate"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
      And I press "Save"
    Then I should see "The field 'Summary' must not be empty."
    
  @ok
  Scenario: user tries to create Debate without title
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
      And I follow "Open a New Debate"
      And I fill in the following:
        | question_statement_document_text | A Debate for all Seasons |
      And I press "Save"
    Then I should see "The field 'Title' must not be empty."
    
  @ok
  Scenario: user creates Debate without tags, then edits it and adds a new tag
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
      And I follow "Open a New Debate"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
      And I press "Save"
    Then I should see "A Debate for all Seasons"
    When I follow "Edit"
      And I fill in the following: 
        | question_statement_document_text  | I wish this text was not so repetitive |
        | question_tags                     | first_tag |
      And I press "Save"
    Then I should see "A Debate for all Seasons"
    
  @ok
  Scenario: user creates Debate with multiple tags
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
      And I follow "Open a New Debate"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_tags                     | first_tag second_tag third_tag|
      And I press "Save"
    Then I should see "A Debate for all Seasons"
    Then the question "A Debate for all Seasons" should have "first_tag second_tag third_tag" as tags
    
  @ok
  Scenario: user creates Debate with multiple tags, then deletes some
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
      And I follow "Open a New Debate"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_tags                     | first_tag second_tag third_tag|
      And I press "Save"
      And I follow "Edit"
      And I fill in the following: 
        | question_tags                     | first_tag |
      And I press "Save"
    Then the question "A Debate for all Seasons" should have "first_tag" as tags
    
  
  @ok
  Scenario: user creates Debate with an hash tag, and it should fail
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
      And I follow "Open a New Debate"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_tags                     | #echonomyjam |
      And I press "Save"      
    Then I should see "#echonomyjam"
    Then I should see "is a topic tag and can only be defined by the Editor"
    
  @ok
  Scenario: editor creates Debate with an hash tag echonomyjam, and it should be visible in the echonomy jam listing
    Given I am logged in as "editor" with password "true"
    When I am on the Discuss Index
      And I follow "Open a New Debate"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_tags                     | #echonomyjam |
      And I press "Save"   
    When I am on the Discuss Index
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"   
      Then I should see "A Debate for all Seasons"
    
    
  
  @ok
  Scenario: user creates Debate with a tag, then edits the debate and adds an invalid tag, and it should fail
    Given I am logged in as "user" with password "true"
    When I am on the Discuss Index
      And I follow "Open a New Debate"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_tags                     | first_tag |
      And I press "Save"      
      And I follow "Edit"
      And I fill in the following:
        | question_tags                     | first_tag #echonomyjam |
      And I press "Save"   
    Then I should see "#echonomyjam"
    Then I should see "is a topic tag and can only be defined by the Editor"