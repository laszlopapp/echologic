Feature: Manage spoken languages
  In order to setup my profile data
  As an user
  I want to create and manage my spoken languages

  # Users may add memberships through the form at the profile page.

  Scenario: Add new spoken language, edit it and try to add it again
    Given I am logged in as "user" with password "true"
      And I have no spoken languages
    When I go to the profile
      And I select "Portuguese" from "spoken_language_language_id"
      And I select "Mother Tongue" from "spoken_language_level_id"
      And I press "new_spoken_language_submit"
    Then I should see "Portuguese"
      And I should see "Mother Tongue"
    Given I go to the profile
      And  I select "Portuguese" from "spoken_language_language_id"
      And I select "Basic" from "spoken_language_level_id"
      And I press "new_spoken_language_submit"
    Then I should see localized "users.spoken_languages.error_messages.repeated_instance"