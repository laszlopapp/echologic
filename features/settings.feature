@settings @0.2

  Scenario: View settings
    Given I am logged in as "user" with password "true"
    When I go to my settings
    Then I should see the "email_notification" container
      And I should see the "drafting_notification" container
      
      
#  Scenario: Check email notification
#    Given I am logged in as "user" with password "true"
#      And I have the email notification disabled
#    When I go to my settings
#      And I check "email_notification"
#    Then I must have the email notification enabled
    
#  Scenario: Uncheck email notification
#    Given I am logged in as "user" with password "true"
#      And I have the email notification enabled
#    When I go to my settings
#      And I uncheck "email_notification"
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