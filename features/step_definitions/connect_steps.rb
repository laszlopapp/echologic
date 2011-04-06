Then /^I should see the profile of "([^\"]*)"$/ do |name|
  response.should contain(name)
end

Then /^I should not see the profile of "([^\"]*)"$/ do |name|
  response.should_not contain(name)
end

When /^I follow the "([^\"]*)" link for the profile of "([^\"]*)"$/ do |link, name|
  profile = Profile.find_by_full_name(name)
  response.should have_selector("#profile_#{profile.id} a.#{link.downcase!}_link") do |selector|
      visit selector.first['href']
  end
end

Then /^I should see the profile details of "([^\"]*)"$/ do |name|
  within("#profile_details_container") do |content|
    response.should contain(name)
  end
end

And  /^my profile is complete enough$/ do
  @user.completeness.should >= 0.5
end


And  /^my profile is not complete enough$/ do
  @user.completeness.should < 0.5
end

Then /^I should be redirected to "(.*)"$/ do |url|
  response.should redirect_to(url)
end

When /^I search for "([^\"]*)"$/ do |search_terms|
  visit connect_search_path(:search_terms => search_terms)
end

