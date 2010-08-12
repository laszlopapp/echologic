Given /^I have a blank profile$/ do
  @user.profile = Profile.new
end

Given /^I have the email notification enabled$/ do
  @user.reload
  @user.update_attribute(:email_notification, true)
end

Given /^I have the email notification disabled$/ do
  @user.reload
  @user.update_attribute(:email_notification, false)
end

Then /^I must have the email notification enabled$/ do
  @user.reload
  assert @user.email_notification
end

Then /^I must have the email notification disabled$/ do
  @user.reload
  assert !@user.email_notification
end