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