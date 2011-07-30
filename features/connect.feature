@connect @0.3
Feature: Use connect functionality
  In order to find other users
  As an user
  I want to type in search values and see the results

  # Within the connect area users are able to view the
  # list of users.

  Scenario: View user list
    Given I am logged in as "user" with password "true"
    And my profile is complete enough
    When I am on the connect page
    Then I should see the profile of "blue Echmeier"
      And I should see the profile of "charlotte Echmeier"
      And I should see the "Search" form

  # As an logged in user, without a complete enough profile
  # i cannot access the connect area

  Scenario: Try to access connect with too empty profile
    Given I am logged in as "Joe" with password "true"
    And my profile is not complete enough
    When I go to the connect page
    Then I should see the "profile" teaser

  # As an logged in user I am able to search for everything
  # ones profile includes:
  #  Name, Email, Concernment, Location, Motivation, About me

  Scenario Outline: Find users by different values
    Given I am logged in as "user" with password "true"
    And my profile is complete enough
    When I go to the connect page
      And I search for "<value>"
    Then I should see the profile of "<true>"
      And I should not see the profile of "<false>"

    Examples:
      | value   | true | false |
      | Energy  | Ben  | Admin |
      | Joe     | Joe  | Ben   |
      | Berlin  | blue | Ben   |
      | Germany | blue | Admin |
      | I am    | blue | Ben   |
      | Pantha  | Joe  | Admin |
      | user@e  | User | Joe   |

  # If they are interested in someones user details they
  # are able to view it - and to close the details.

  Scenario: View user details
    Given I am logged in as "user" with password "true"
    And my profile is complete enough
    And I am on the connect page
    When I follow the "Show" link for the profile of "blue Echmeier"
    Then I should see the profile details of "blue Echmeier"
      And I should see a "Close" link


  # I know it's not really user storie like to talk about a mysterious flag, but i found it hard to put the logic behind it in better words, because 'complete enough' would make a developer assume that we're dealing with the completeness value

  Scenario: Don't show Users without a complete enough profile (show_profile flag not set)
    Given I am logged in as "user" with password "true"
    And my profile is complete enough
    And the profile of user "luise echmeier" has no show_profile flag
    And I am on the connect page
    Then I should not see the profile of "luise echmeier"
    
  
    
  Scenario: Send an email to another user
    Given I am logged in as "user" with password "true"
    When I am on the connect page
      And I follow the "Show" link for the profile of "User Test"
    Then I should not see localized "connect.details.actions.send_mail" within "#profile_details_container #actions"
      And I go to the connect page
      And I follow the "Show" link for the profile of "Ben Test"
      And I follow localized "connect.details.actions.send_mail" within "#profile_details_container #actions"
      And I fill in the following:
      | user_mail_subject | I Like the Subject |
      | user_mail_text    | I Like the Text    |
      And I press "Send"
    Then I should see localized "user_mail.create.thank_you"
      And an "echo message" email should be sent to "ben@echologic.org"