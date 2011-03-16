@settings @0.2

Feature: Set my settings
  Scenario: View settings
    Given I am logged in as "user" with password "true"
    When I go to my settings
    Then I should see the "activity" notifications
    Then I should see the "drafting" notifications
    Then I should see the "newsletter" notifications


#  Scenario: Check email notification
#    Given I am logged in as "user" with password "true"
#      And I have the email notification disabled
#    When I go to my settings
#      And I check "activity_notification"
#    Then I must have the email notification enabled

#  Scenario: Uncheck email notification
#    Given I am logged in as "user" with password "true"
#      And I have the email notification enabled
#    When I go to my settings
#      And I uncheck "activity_notification"
#    Then I must have the email notification disabled

#  Scenario: Check drafting notification
#    Given I am logged in as "user" with password "true"
#      And I have the drafting notification disabled
#    When I go to my settings
#      And I check "drafting_notification"
#    Then I must have the drafting notification enabled

#  Scenario: Uncheck drafting notification
#    Given I am logged in as "user" with password "true"
#      And I have the drafting notification enabled
#    When I go to my settings
#      And I uncheck "drafting_notification"
#    Then I must have the drafting notification disabled

  Scenario: Change Email
    Given I am logged in as "user" with password "true"
    When I go to my settings
      And I follow "change_email"
      And I fill in the following:
      | user_email                | thedarksideofthemoon@sun.com |
      | user_email_confirmation   | thedarksideofthemoon@sun.com |
      | user_password             | true                         |
      And I press "Ok"
    Then I should see localized "users.users.messages.email_updated"
    Then an "activate" email should be sent to "thedarksideofthemoon@sun.com"
  
  Scenario: Change Password Fail
    Given I am logged in as "user" with password "true"
    When I go to my settings
      And I follow "change_password"
      And I fill in the following:
      | user_old_password            | malaka  |
      | user_password                | dzenkui |
      | user_password_confirmation   | dzenkui |
      And I press "Ok"
    Then I should see "The password you entered is not your password!"
    
  Scenario: Change Password 
    Given I am logged in as "user" with password "true"
    When I go to my settings
      And I follow "change_password"
      And I fill in the following:
      | user_old_password            |  true   |
      | user_password                | dzenkui |
      | user_password_confirmation   | dzenkui |
      And I press "Ok"
    Then I should see "Password changed successfully!"
      And "User Test" should have "dzenkui" as password
      
      
  Scenario: Delete Account
    Given I am logged in as "user" with password "true"
    When I go to my settings
      And I follow "delete_account"
      And I follow "destroy_account"
    Then I should see "Your echo account was successfully deleted."
      And I should be inactive