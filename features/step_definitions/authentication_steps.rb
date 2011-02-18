# Login process for given user and password. If user isn't in email format
# the standard mail ending will be appended.
When /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |user, password|
  user += "@echologic.org" unless user =~ /.*@.*\..{2,3}/
  visit signin_url
  fill_in('user_session_email', :with => user)
  fill_in('user_session_password', :with => password)
  click_button('user_session_submit')
  @user = User.find_by_email(user)
end

When /^I login as "([^\"]*)" with password "([^\"]*)"$/ do |user, password|
  Then "I am logged in as \"#{user}\" with password \"#{password}\""
end

Given /^"([^\"]*)" forgot his password$/ do |user_full_name|
  user_names = user_full_name.split(" ")
  @user = Profile.find_by_first_name_and_last_name(user_names.first,user_names.last).user
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

Given /^"([^\"]*)" is an unregistered user with "([^\"]*)" as an email$/ do |user_full_name, email|
  user_names = user_full_name.split(" ")
  @user = User.new
  @user.create_profile
  @user.signup!(:first_name => user_names.first, :last_name => user_names.last, :email => email)
end

Then /^"([^\"]*)" should have "([^\"]*)" as "([^\"]*)"$/ do |user, code, attribute|
  user += "@echologic.org" unless user =~ /.*@.*\..{2,3}/
  @user = User.find_by_email(user)
  key = EnumKey.find_by_code(code)
  assert @user.send(attribute.to_sym).eql?(key)
end

Then /^an "([^\"]*)" email should be sent to "([^\"]*)"$/ do |email_type, email_address|
  assert !ActionMailer::Base.deliveries.empty?
  email = ActionMailer::Base.deliveries.first
  assert_equal [email_address], email.to
  assert_match /#{email_type}/, email.subject
end


Then /^"([^\"]*)" should have "([^\"]*)" as password$/ do |user_full_name, password|
  user_names = user_full_name.split(" ")
  user = Profile.find_by_first_name_and_last_name(user_names.first,user_names.last).user
  u_session = UserSession.new(:email => user.email, :password => password)
  assert u_session.save
end

Then /^"([^\"]*)" should have a profile$/ do |user_full_name|
  user_names = user_full_name.split(" ")
  profile = Profile.find_by_first_name_and_last_name(user_names.first,user_names.last)
  assert !profile.nil?
end