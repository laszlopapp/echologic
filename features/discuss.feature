@discuss @user
Feature: Take Part on a discussion
  In order to take part on a discussion
  As a user
  I want to give different kind of statements on questions


  # Within the discuss area the list of debates should be
  # correctly ordered (by date of creation)

  Scenario: View debates list
    Given I am logged in as "user" with password "true"
    And I am on the Discuss Index
  	When I follow "Featured"
  	When I follow "echonomy JAM"
    	When I choose the first question
    	When I choose the second question
    Then the second question must be more recent than the first question
        
    
  @ok
  Scenario: Open a question
    Given I am logged in as "user" with password "true"
      And I am on the Discuss Index
    When I follow "Featured"
    When I follow "echonomy JAM"
      And I choose the first question
    Then I should see the questions title
  
  @ok
  Scenario: Add a proposal to a question
    Given I am logged in as "user" with password "true"
      And there is the first question
      And the question has no proposals
      And I am on the Discuss Index
    When I follow "Featured"
    When I follow "echonomy JAM"
      And I choose the first Question
      And I follow "Enter a new proposal"
      And I fill in the following:
        | proposal_document_title | a proposal to propose some proposeworthy proposal data |
        | proposal_document_text | nothing to propose yet...                              |
      And I press "Save"
    Then I should be on the question
      And I should see "a proposal to propose some"
      And the question should have one proposal

  @ok
  Scenario: Add an Improvement Proposal to a Proposal
    Given I am logged in as "user" with password "true"
      And there is the first question
      And the question has at least on proposal
    When I go to the questions first proposal
      And I follow localized "discuss.statements.create_improvement_proposal_link"
      And I fill in the following:
      | improvement_proposal_document_title | Improving the unimprovable                                           |
      | improvement_proposal_document_text  | blubb (oh, and of cause a lot of foo and a little bit of (mars-)bar) |
      And I press "Save"
    Then I should be on the proposal
      And I should see "Improving the unimprovable"
      And the proposal should have one improvement proposal

  @ok
  Scenario: Edit a proposal i created
    Given I am logged in as "user" with password "true"
      And there is a proposal I have created
     When I go to the proposal
     Then I should not see "Edit"
   #   And I follow "edit"
   #   And I fill in the following:
   #    | title | my updated proposal               |
   #    | text  | somewhat more to propose at lease |
   #   And I press "Save"
   # Then I should see "my updated proposal"
   #   And the questions title should be "my updated proposal"

   # @CHECK
   # Scenario: View an statement (document) that is not oriinally in my locale language but has translations in another language i speak
   #   Given I am logged in as "user" with password "true"
   #   And my locale language is "de" locale language is "de"
   #   And i also speak the languages "en, fr"
   #   And there is a a proposal in "de" with translations in "en"
   #   When I go to the proposal
   #   Then I should see the proposals english translation
   #   And I should see something like "This proposal is not available in your locale language, but there is an english translation"
   #   And I should see "Translate this proposal"

   # @CHECK
   # Scenario: View an statement (document) that is not originally in my locale language but has translations in several other language i speak
   #   Given I am logged in as "user" with password "true"
   #   And my locale language is "de"
   #   And i also speak the languages "en, fr"
   #   And there is a a proposal in "de" with translations in "en, fr"
   #   When I go to the proposal
   #   Then I should see the proposals english translation
   #   And I should see something like "This proposal is not available in your locale language, but there is an english translation"
   #   And I should see "Translate this proposal"

   # @TODO @CHECKBOXES
   # Scenario: View an statement (document) that is not in my locale language and has no translations in any language i speak 
   #   Given I am logged in as "user" with password "true"
   #   And my locale language is "de"
   #   And i also speak the languages "en, fr"
   #   And there is a a proposal in "de" with no translations
   #   When I go to the proposals
   #   TODO: ...

   # @CHECKBOXES
   # Scenario: View a debate with a proposal that is not available in any language I speaks
   #   Given I am logged in as "user" with password "true"
   #   And my locale language is "de"
   #   And I also speak the languages "en"
   #   And there is a question in the language "en" with a proposal in language "fr" and titile "C'est la vie!"
   #   When I go to the question
   #   Then I shouldn't see "C'est la vie!"
   #   And there shouldn't be any proposals for the question 

   # @TODO @CHECKBOXES
   # Scenario: Translate a statement from a language i speak into my locale language
   #   Given I am logged in as "user" with password "true"
   #   And my locale language is "de"
   #   And I also speak the languages "en"
   #   And there is a a proposal in "en" with no translations
   #   When I go to the proposal
   #   And I click "Translate this proposal"
   #   And I fill in the following
   #   TODO: ... statement_document_title, statement_document_test
   #   And I press "Save"
   #   Then I should see "You successfully translated this proposal"
   #   And I should see "TODO: what I entered as a title"
   #   And the proposal should have translations in "en, de"

# Open Questions:

# * should we always display in which other languages the statement might also exist, or always trust that the order of languages the user speaks is right"? 
# ** Do we have an order of languages anyway? If the user can only use checkboxes for selecting languages she speaks, it's impossible to figure out more order than local language, other languages.
# In this case we should really display the user in what languages (he speaks) the statement has translations

# * what should i actually see when i navigate directly to a proposal without a translation into any language i speak (for example through an direct link?)

   Scenario: View a proposal
     Given I am logged in as "user" with password "true"
       And there is a proposal
     When I go to the proposal
     Then I should see localized "discuss.summary"
       And I should see the proposals data
       And I should see localized "discuss.statements.create_improvement_proposal_link"
       And I should see localized "discuss.statements.create_proposal_link"

