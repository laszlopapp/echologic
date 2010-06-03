
When /^I press localized "([^\"]*)"$/ do |key|
  click_button(I18n.t(key)) # or even I18n.t(key, :default => key) if you want to be able to use the key itself as the default
end

When /^(?:|I )follow localized "([^\"]*)"$/ do |key|
  click_link(I18n.t(key))
end

When /^(?:|I )follow localized "([^\"]*)" within "([^\"]*)"$/ do |key, parent|
  click_link_within(parent, I18n.t(key))
end

Then /^I should see localized "([^\"]*)"$/ do |key|
  puts I18n.t(key)
  response.should contain(I18n.t(key))  
end

Then /^I should not see localized "([^\"]*)"$/ do |key|
  response.should_not contain(I18n.t(key))
end
