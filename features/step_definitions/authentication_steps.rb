# Login process for given user and password. If user isn't in email format
# the standard mail ending will be appended.
When /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |user, password|
  user += "@echologic.org" unless user =~ /.*@.*\..{2,3}/
  visit root_url
  fill_in('user_session_email', :with => user)
  fill_in('user_session_password', :with => password)
  click_button('user_session_submit')
  @user = User.find_by_email(user)
end

When /^I login as "([^\"]*)" with password "([^\"]*)"$/ do |user, password|
  user += "@echologic.org" unless user =~ /.*@.*\..{2,3}/
  fill_in('user_session_email', :with => user)
  fill_in('user_session_password', :with => password)
  click_button('user_session_submit')
  @user = User.find_by_email(user)
end


When /^I let my session expire$/ do
  @normal_expiry_time = MAX_SESSION_PERIOD
  MAX_SESSION_PERIOD = 0
  # controller.send(:current_user_session).destroy
end

When /^I restore normal session expiry time$/ do 
  MAX_SESSION_PERIOD = @normal_expiry_time
  # controller.send(:current_user_session).destroy
end

Then /^"([^\"]*)" should have "([^\"]*)" as "([^\"]*)"$/ do |user, code, attribute|
  user += "@echologic.org" unless user =~ /.*@.*\..{2,3}/
  @user = User.find_by_email(user)
  key = EnumKey.find_by_code(code)
  assert @user.send(attribute.to_sym).eql?(key)
end