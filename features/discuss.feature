@discuss @UserSession
Feature: Take Part on a question
  In order to take part on a question
  As a user
  I want to give different kind of statements on questions


  # Within the discuss area the list of debates should be
  # correctly ordered (by date of creation)

  # FIXME this can't work in this way, and should anyway rather being tested inside a functional test

  Scenario: View debates list
     Given I am logged in as "user" with password "true"
     And I am on the Discuss Index
     When I follow localized "discuss.featured_topics.title"
     When I follow "echonomyJAM"
       When I choose the first Question
     And I am on the Discuss Index
     When I follow localized "discuss.featured_topics.title"
     When I follow "echonomyJAM"
       When I choose the second Question
     Then the second question must be more recent than the first question

  # Navigation prev/next button
  @ok
  Scenario: Navigate with the navigation button through the questions
    Given I am logged in as "user" with password "true"
      And I am on the Discuss Index
      And I see a group of questions
    When I choose the first Question
      Then I should see the group of question titles while pressing the next button
      Then I should see the group of question titles while pressing the prev button


  @ok
  Scenario: Navigate with the next button through the proposals
    Given I am logged in as "user" with password "true"
      And I am on the Discuss Index
      And I choose the "Test Question2?" Question
      And I see a group of proposals
    When I choose the first Proposal
      Then I should see the group of proposal titles while pressing the next button
      Then I should see the group of proposal titles while pressing the prev button

  @ok
  Scenario: Navigate with the next button through the improvements
    Given I am logged in as "user" with password "true"
      And I am on the Discuss Index
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And I see a group of improvements
    When I choose the first Improvement
      Then I should see the group of improvement titles while pressing the next button
      Then I should see the group of improvement titles while pressing the prev button

  @ok
  Scenario: Open a question
    Given I am logged in as "user" with password "true"
      And I am on the Discuss Index
    When I follow localized "discuss.featured_topics.title"
    When I follow "echonomyJAM"
      And I choose the first Question
    Then I should see the questions title

  @ok
  Scenario: Add a proposal to a question
    Given I am logged in as "user" with password "true"
      And there is the first question
      And the question has no proposals
      And I am on the Discuss Index
    When I follow localized "discuss.featured_topics.title"
    When I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I follow localized "discuss.statements.create_proposal_link"
      And I fill in the following:
        | proposal_statement_document_title | a proposal to propose some proposeworthy proposal data |
        | proposal_statement_document_text | nothing to propose yet...                              |
      And I press "Save"
      Then I should see "a proposal to propose some"
      And the question should have one proposal

  @ok
  Scenario: Add an Improvement to a Proposal
    Given I am logged in as "user" with password "true"
      And there is the first question
      And the question has at least one proposal
    When I go to the questions first proposal
      And I follow localized "discuss.statements.create_improvement_link"
      And I fill in the following:
      | improvement_statement_document_title           | Improving the unimprovable                                           |
      | improvement_statement_document_text           | blubb (oh, and of cause a lot of foo and a little bit of (mars-)bar) |
      And I press "Save"
    Then I should see "Improving the unimprovable"
      And the proposal should have one improvement

  # TEST THE 'ADD NEW' SECTION

  @ok
  Scenario: Add a sibling question
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow "Search"
      And I choose the "Test Question2?" Question
    Then the question should have 5 siblings in session
      And I follow localized "discuss.statements.types.question" within ".add_new_panel"
      And I fill in the following:
      | question_statement_document_title           | Question on the side              |
      | question_statement_document_text            | i like big butts and i cannot lie |
      And I press "Save"
    Then I should see "Question on the side"
      And the question should have 6 siblings in session

  Scenario: Add a sibling Proposal
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
    Then the proposal should have 0 siblings in session
      And I follow localized "discuss.statements.types.proposal" within ".add_new_panel"
      And I fill in the following:
      | proposal_statement_document_title           | How to propose to women   |
      | proposal_statement_document_text            | i find you very atractive |
      And I press "Save"
    Then I should see "How to propose to women"
      And the proposal should have 1 siblings in session

  Scenario: Add a sibling Improvement
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And I choose the "A better first proposal" Improvement
    Then the improvement should have 4 siblings in session
      And I follow localized "discuss.statements.types.improvement" within ".add_new_panel"
      And I fill in the following:
      | improvement_statement_document_title           | How to improve yer status    |
      | improvement_statement_document_text            | Eat the poor                 |
      And I press "Save"
    Then I should see "How to improve yer status"
      And the improvement should have 5 siblings in session

  Scenario: Add a Proposal to a Question
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I follow localized "discuss.statements.types.proposal" within ".add_new_panel"
      And I fill in the following:
      | proposal_statement_document_title           | How to propose to women   |
      | proposal_statement_document_text            | i find you very atractive |
      And I press "Save"
    Then I should see "How to propose to women"
      And the proposal should have 1 siblings in session

  Scenario: Add an Improvement to a proposal
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And I follow localized "discuss.statements.types.improvement" within ".add_new_panel"
      And I fill in the following:
      | improvement_statement_document_title           | How to improve yer status    |
      | improvement_statement_document_text            | Eat the poor                 |
      And I press "Save"
    Then I should see "How to improve yer status"
      And the improvement should have 5 siblings in session

  Scenario: Add a Pro Argument to a proposal
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And I follow localized "discuss.statements.types.pro_argument" within ".add_new_panel"
      And I fill in the following:
      | pro_argument_statement_document_title           | Pro 4 life                   |
      | pro_argument_statement_document_text            | I submit this pro-life stand |
      And I press "Save"
    Then I should see "Pro 4 life"
      And the pro argument should have 0 siblings in session

  Scenario: Add a Pro Argument to a proposal
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And I follow localized "discuss.statements.types.contra_argument" within ".add_new_panel"
      And I fill in the following:
      | contra_argument_statement_document_title           | Contra is cool    |
      | contra_argument_statement_document_text            | Best Game... EVA! |
      And I press "Save"
    Then I should see "Contra is cool"
      And the contra argument should have 0 siblings in session

  Scenario: Add a Follow Up Question to a Question
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I follow localized "discuss.statements.types.follow_up_question" within ".add_new_panel"
      And I fill in the following:
      | follow_up_question_statement_document_title           | Livin it up      |
      | follow_up_question_statement_document_text            | I love this game |
      | follow_up_question_topic_tags                         |                  |
      And I press "Save"
    Then I should see "Livin it up"
      And the question should have 0 siblings in session
      And there should be a "Test Question2?" breadcrumb
    Given I go to the question
    Then I should see "Livin it up"
    Given I follow "Logout"
    Then I should not see "Livin it up"
    Given I login as "ben" with password "benrocks"
    Then I should not see "Livin it up"

  Scenario: Add a Follow Up Question to a Proposal
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And I follow localized "discuss.statements.types.follow_up_question" within ".add_new_panel"
      And I fill in the following:
      | follow_up_question_statement_document_title           | Livin it up      |
      | follow_up_question_statement_document_text            | I love this game |
      | follow_up_question_topic_tags                         |                  |
      And I press "Save"
    Then I should see "Livin it up"
      And the question should have 0 siblings in session
      And there should be a "A first proposal!" breadcrumb

  Scenario: Add a Follow Up Question to an Improvement
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And I choose the "A better first proposal" Improvement
      And I follow localized "discuss.statements.types.follow_up_question" within ".add_new_panel"
      And I fill in the following:
      | follow_up_question_statement_document_title           | Livin it up      |
      | follow_up_question_statement_document_text            | I love this game |
      | follow_up_question_topic_tags                         |                  |
      And I press "Save"
    Then I should see "Livin it up"
      And the question should have 0 siblings in session
      And there should be a "A better first proposal" breadcrumb

  Scenario: Add a Follow Up Question to an Improvement, then a Follow Up Question to that question
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And I choose the "A better first proposal" Improvement
      And I follow localized "discuss.statements.types.follow_up_question" within ".add_new_panel"
      And I fill in the following:
      | follow_up_question_statement_document_title           | Livin it up      |
      | follow_up_question_statement_document_text            | I love this game |
      | follow_up_question_topic_tags                         |                  |
      And I press "Save"
    Then I should see "Livin it up"
      And the question should have 0 siblings in session
      And there should be a "A better first proposal" breadcrumb
    When I follow localized "discuss.statements.types.follow_up_question" within ".add_new_panel"
      And I fill in the following:
      | follow_up_question_statement_document_title           | Livin it up Part Deux     |
      | follow_up_question_statement_document_text            | I still love this game    |
      And I press "Save"
    Then I should see "Livin it up Part Deux"
      And the question should have 0 siblings in session



  @ok
  Scenario: Edit a proposal i created
    Given I am logged in as "user" with password "true"
      And there is a proposal I have created
      And the proposal was not published yet
     When I go to the proposal
     Then I should see "Edit"
      And I follow "Edit"
      And I fill in the following:
       | proposal_statement_document_title | my updated proposal               |
       | proposal_statement_document_text  | somewhat more to propose at lease |
      And I press "Save"
    Then I should see "my updated proposal"


# Open Questions:

# * should we always display in which other languages the statement might also exist, or always trust that the order of languages the user speaks is right"?
# ** Do we have an order of languages anyway? If the user can only use checkboxes for selecting languages she speaks, it's impossible to figure out more order than local language, other languages.
# In this case we should really display the user in what languages (he speaks) the statement has translations

# * what should i actually see when i navigate directly to a proposal without a translation into any language i speak (for example through an direct link?)

   Scenario: View a proposal
     Given I am logged in as "user" with password "true"
       And there is a proposal
     When I go to the proposal
     Then I should see "Proposal"
       And I should see the proposal data
       And I should see localized "discuss.statements.create_improvement_link"


   Scenario: Question has only proposals in german, which will not be seen by a user with no defined german language
    Given I am logged in as "red" with password "red"
      And I am on the Discuss Index
    When I follow localized "discuss.featured_topics.title"
    When I follow "echonomyJAM"
      And I choose the "I only have kids in German" Question
      And the question has proposals
      Then I should see no proposals


  Scenario: Incorporate an approved statement
    Given I am logged in as "ben" with password "benrocks"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And the proposal has an approved child
      And I go to the proposal
      And I follow localized "application.general.incorporate"
      And I fill in the following:
       | proposal_statement_document_title | Incorporated Title               |
       | proposal_statement_document_text  | corporative beast                |
      And I press "Save"
    Then I should see "corporative beast"
      And the proposal has no approved children
      And the proposal has incorporated children
      And a "send_incorporation_mails" delayed job should be created


  Scenario: User tries to edit, gets out of the form and editor can't edit it
    Given I am logged in as "user" with password "true"
      And there is a question i have created
      And the question was not published yet
    When I go to the question
      And I follow "Edit"
      And I follow "Logout"
    Given I am logged in as "editor" with password "true"
    When I go to the question
      And I follow "Edit"
    Then I should see localized "discuss.statements.being_edited"

  Scenario: User tries to edit, cancels and editor can edit it
    Given I am logged in as "user" with password "true"
      And there is a question i have created
      And the question was not published yet
    When I go to the question
      And I follow "Edit"
      And I follow "Cancel"
      And I follow "Logout"
    Given I am logged in as "editor" with password "true"
    When I go to the question
      And I follow "Edit"
    Then I should not see localized "discuss.statements.being_edited"

  Scenario: User sees the edit button, then someone supports it, and then there is no more edit for no one
    Given I am logged in as "user" with password "true"
      And there is a question i have created
    When I go to the question
      Then I should see localized "application.general.edit" within ".action_buttons"
    Given I follow "Logout"
      And I am logged in as "ben" with password "benrocks"
      And I go to the question
      And I follow "echo_button"
      And I follow "Logout"
      And I am logged in as "user" with password "true"
      And I go to the question
    Then I should not see localized "application.general.edit" within ".action_buttons"

  Scenario: Ben edits for incorporation, doesn't make it, editor tries to edit and can't
    Given I am logged in as "ben" with password "benrocks"
      And I am on the discuss index
    When I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And the proposal has an approved child
      And I go to the proposal
      And I follow localized "application.general.incorporate"
      And I follow "Logout"
    Given I am logged in as "editor" with password "true"
      When I go to the proposal
        And I follow "Edit"
      Then I should see localized "discuss.statements.being_edited"

  Scenario: Editor tries to edit, gets out of the form and ben can't incorporate it
    Given I am logged in as "editor" with password "true"
    When I am on the discuss index
      And I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I choose the "A first proposal!" Proposal
      And I follow "Edit"
      And I follow "Logout"
    Given I am logged in as "ben" with password "benrocks"
      And the proposal has an approved child
      And I go to the proposal
      And I follow localized "discuss.tooltips.incorporate"
    Then I should see localized "discuss.statements.being_edited"


  Scenario: User checks authors from a statement
    Given I am logged in as "user" with password "true"
    When I am on the discuss index
      And I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question2?" Question
      And I follow "Authors"
    Then I should see "Edi Tor"


#  Scenario: User open a previously closed children's block
#    Given proposals are not immediately loaded on questions
#      And I am logged in as "user" with password "true"
#      And I am on the discuss index
#      And I follow localized "discuss.featured_topics.title"
#      And I follow "echonomyJAM"
#      And I choose the "Test Question?" Question
#      And there are hidden proposals for this question
#      And I follow "proposals"
#    Then I should see the hidden proposals

  Scenario: User presses more button on question's proposals children block
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
      And I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question?" Question
      And there are hidden proposals for this question
      And I follow localized "application.general.more" within ".proposals"
      # needed because of the TOP CHILDREN mechanism
      And I follow localized "application.general.more" within ".proposals"
    Then I should see the hidden proposals

  Scenario: User opens question's siblings block
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
      And I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question?" Question
    Then I should not see "Test Question2?"
      And I follow "Questions" within ".header_buttons"
    Then I should see "Test Question2?"

  Scenario: User opens proposal's siblings block
    Given I am logged in as "user" with password "true"
      And I am on the discuss index
      And I follow localized "discuss.featured_topics.title"
      And I follow "echonomyJAM"
      And I choose the "Test Question?" Question
      And I choose the "Second Proposal" Proposal
    Then I should not see "Eighth Proposal"
      And I follow "Proposals" within ".proposal .header_buttons"
    Then I should see "Eighth Proposal"
