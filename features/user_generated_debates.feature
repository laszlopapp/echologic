Feature: User Generated Debates

  @ok
  Scenario: Unlogged user unable to access My Questions
    When I am on the Discuss Index
      And I follow "My Questions"
    Then I should see "Please log in to perform this action"

  @ok
  Scenario: user tries to create Debate without content
    Given I am logged in as "user" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I press "Save"
    Then I should see "The field 'Title' must not be empty."
    Then I should see "The field 'Summary' must not be empty."

  @ok
  Scenario: user tries to create Debate without text
    Given I am logged in as "user" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
      And I press "Save"
    Then I should see "The field 'Summary' must not be empty."

  @ok
  Scenario: user tries to create Debate without title
    Given I am logged in as "user" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I fill in the following:
        | question_statement_document_text | A Debate for all Seasons |
      And I press "Save"
    Then I should see "The field 'Title' must not be empty."

  @ok
  Scenario: user creates Debate without tags, then edits it and adds a new tag
    Given I am logged in as "user" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
      And I press "Save"
    Then I should see "A Debate for all Seasons"
    When I follow "Edit"
      And I fill in the following:
        | question_statement_document_text  | I wish this text was not so repetitive |
        | question_topic_tags                     | first_tag |
      And I press "Save"
    Then I should see "The Question has been updated successfully."

  @ok
  Scenario: user creates Debate with multiple tags
    Given I am logged in as "user" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_topic_tags                     | first_tag,second_tag,third_tag|
      And I press "Save"
    Then I should see "The new Question has been entered successfully."
    Then the question "A Debate for all Seasons" should have "first_tag, second_tag, third_tag" as tags

  @ok
  Scenario: user creates Debate with multiple tags, then deletes some
    Given I am logged in as "user" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_topic_tags                     | first_tag,second_tag,third_tag|
      And I press "Save"
      And I follow "Edit"
      And I fill in the following:
        | question_topic_tags                     | first_tag |
      And I press "Save"
    Then the question "A Debate for all Seasons" should have "first_tag" as tags


  @ok
  Scenario: user creates Debate with an hash tag, and it should fail
    Given I am logged in as "user" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_topic_tags                     | #echonomyjam |
      And I press "Save"
    Then I should see "#echonomyjam"
    Then I should see "You do not have the permission to insert the "

  @ok
  Scenario: editor creates Debate with an hash tag echonomyjam, and it should be visible in the echonomy jam listing
    Given I am logged in as "editor" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_topic_tags                     | #echonomyjam |
      And I choose "Publish immediately (no further editing is possible)"
      And I press "Save"
    When I am on the discuss featured
    When I follow "Pilot Projects"
    When I follow "echonomyJAM"
      Then I should see "A Debate for all Seasons"



  @ok
  Scenario: user creates Debate with a tag, then edits the debate and adds an invalid tag, and it should fail
    Given I am logged in as "user" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_topic_tags                     | first_tag |
      And I press "Save"
      And I follow "Edit"
      And I fill in the following:
        | question_topic_tags                     | first_tag,#echonomyjam |
      And I press "Save"
    Then I should see "#echonomyjam"
    Then I should see "You do not have the permission to insert the "

  @ok
  Scenario: user creates Debate, then goes to his My Questions area and should publish it successfully
    Given there are no questions
    Given I am logged in as "user" with password "true"
    When I am on My Questions
      And I follow "Create a new question"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_topic_tags                     | first_tag |
      And I press "Save"
      And I go to "My Questions"
      And I follow "Release"
    Then I should not see "Release"

  @ok
  Scenario: user tries to create echonomyjam debate directly going from the new question link from the echonomyjam side
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
      And I follow "Featured"
      And I follow "echonomyJAM"
      And I follow localized "discuss.statements.create_question_link"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
      And I press "Save"
    Then I should see "You do not have the permission to insert the '#echonomyjam' tag."

  @ok
  Scenario: added a hash tag to a debate when i had the asterisk tag as a decision making tag, and it should work!
    Given I am logged in as "user" with password "true"
      And I have "*xyz" as decision making tags
      And I am on My Questions
      And I follow localized "discuss.my_questions.add"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_topic_tags                     | #xyz |
      And I press "Save"
    Then I should see "The new Question has been entered successfully."
    Then the question "A Debate for all Seasons" should have "#xyz" as tags

  @ok
  Scenario: An editor should define any hash tags
    Given I am logged in as "editor" with password "true"
      And I am on My Questions
      And I follow localized "discuss.my_questions.add"
      And I fill in the following:
        | question_statement_document_title | A Debate for all Seasons |
        | question_statement_document_text  | A Debate for all Seasons |
        | question_topic_tags                     | #new,#echo |
      And I press "Save"
    Then I should see "The new Question has been entered successfully."
    Then the question "A Debate for all Seasons" should have "#new,#echo" as tags