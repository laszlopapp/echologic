Given /^I have a blank profile$/ do
  @user.profile = Profile.new
end

Given /^I have the ([^\"]*) notification enabled$/ do |attr|
  @user.reload
  @user.update_attribute("#{attr}_notification".to_sym, true)
end

Given /^I have the ([^\"]*) notification disabled$/ do |attr|
  @user.reload
  @user.update_attribute("#{attr}_notification".to_sym, false)
end

Then /^I must have the ([^\"]*) notification enabled$/ do |attr|
  @user.reload
  assert @user.send("#{attr}_notification") == 1
end

Then /^I must have the ([^\"]*) notification disabled$/ do |attr|
  @user.reload
  assert !@user.send("#{attr}_notification") == 0
end
