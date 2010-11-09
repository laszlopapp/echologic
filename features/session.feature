Feature: Sessions

Scenario: Surfing the page, and logging in
  Given I am on the discuss index
  When I login as "user" with password "true"
  Then I should be on the discuss featured

Scenario: Logging out and In again
  Given I am logged in as "user" with password "true"
  When I am on the discuss index
  And I follow "Logout"
  And I login as "user" with password "true"
  Then I should be on the welcome page

Scenario: Login after expired Session
  Given I am logged in as "user" with password "true"
  And I am on the discuss index
  When I let my session expire
  And I go to the Discuss Index
  And I go to the Discuss Index
  And I restore normal session expiry time
  And I login as "user" with password "true"
  Then I should be on the discuss featured

Scenario: Logout and save last login language
  Given I am logged in as "user" with password "true"
  And I am on the discuss index
  And I follow "Logout"
  Then "user" should have "en" as "last_login_language"
