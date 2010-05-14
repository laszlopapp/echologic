@web_addresses @0.2
Feature: Manage web addresses
  In order to set web addresses
  As an user
  I want to create and manage web addresses

  # A logged in user have to be able to see his web addresses
  # at the profile.

  Scenario Outline: View web profile list
    Given I am logged in as "user" with password "true"
      And I have the following web addresses:
        | web_address_type_id   | address   |
        | <web_address_type_id> | <address> |
    When I go to the profile
    Then I should see "<address>"
      And I should have 3 web addresses
    
    Examples:
      | web_address_type_id     | address                    |
      | twitter            | http://www.twitter.com/user |
      | blog               | http://blog.com/user        |
      | blog               | http://twitter.com/joe      |
  # When a new web profile is added it should be shown on
  # the users profile page.
  
  Scenario: Add new web profile
    Given I am logged in as "user" with password "true"
      And I have no web addresses
    When I go to the profile
      And I select "Homepage" from "web_address_web_address_type_id"
      And I fill in "web_address_address" with "http://www.homepage.com/user"
      And I press "new_web_address_submit"
    Then I should see "http://www.homepage.com/user"
      And I should have 1 web addresses
