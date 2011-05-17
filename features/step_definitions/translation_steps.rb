Given /^I change the application language to "([^\"]*)"$/ do |code|
  I18n.locale = code
end