@auth @0.2
Feature: Authentication
  In order to authenticate
  As an user
  I want to login with email and password

  # A user must be able to login and see a welcome message.
  Scenario: Successful login
    Given I am logged in as "user" with password "true"
    Then I should be on the welcome page
      And I should see "Login successful."
      And I should see "Logged in"
      And I should see "User Test"

  # A user must be able to logout
  Scenario: Successful Logout
    Given I am logged in as "user" with password "true"
    When I follow "Logout"
    Then I should see "Logout successful."

  # As an user you mustn't see the admin options, as an admin
  # these options must be available.

  Scenario Outline: Show admin options
    Given I am logged in as "<user>" with password "<password>"
    Then I should <action>

    Examples:
      | user  | password | action                  |
      | admin | true     | see the "Admin" tab     |
      | user  | true     | not see the "Admin" tab |

  Scenario: New User registers himself and gets an activation email
    Given I am on the start page
      And I follow "Not a member yet?"
      And I fill in the following:
        | user_profile_first_name | Jesus                                          |
        | user_profile_last_name  | Christ                                         |
        | user_email              | jesus.christ.the.son.not.the.father@heaven.com |
      And I press the "Create" button
    Then an "activate" email should be sent to "Jesus Christ"
      And "Jesus Christ" should have a profile
      
  Scenario: Fresh unregistered User must set his password to complete registration
    Given "Jesus Christ" is an unregistered user with "jesus.christ@iwanttohelppeople.com" as an email
      And I go to the activation page
      And I fill in the following: 
        | user_password             | godisintheinternet |
        |user_password_confirmation | godisintheinternet |
      And I press "Set password and log in"
    Then I should be on the welcome page
      And an "Welcome to echo" email should be sent to "Jesus Christ"
      And "Jesus Christ" should have "godisintheinternet" as password
  
  Scenario: User user forgot his password, and wants to check it
    Given I am on the start page
      And I follow "Forgot your password?"
      And I fill in the following: 
        | email | user@echologic.org |
      And I press "Send E-Mail"
    Then an "New password for echo" email should be sent to "User Test"
  
  Scenario: User user fills the form to have another password
    Given "friedrich Echmeier" forgot his password
      And I go to the edit password page
      And I fill in the following:
        | user_password               | friedrichstrasse |
        | user_password_confirmation  | friedrichstrasse |
      And I press "Set password and log in" 
    Then I should be on the welcome page
      And "friedrich Echmeier" should have "friedrichstrasse" as password