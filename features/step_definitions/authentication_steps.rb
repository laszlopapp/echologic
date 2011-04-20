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

Given /^"([^\"]*)" forgot his password$/ do |name|
  @user = Profile.find_by_full_name(name).user
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

Given /^"([^\"]*)" is an unregistered user with "([^\"]*)" as an email$/ do |name, email|
  @user = User.new
  @user.create_profile
  @user.signup!(:full_name => name, :email => email)
end

Given /^I have no tags$/ do
  @user.tao_tags.destroy_all
  @user.save
end

Given /^ I have "([^\"]*)" as ([^\"]*) tags$/ do |tags, tag_type|
tag_type = tag_type.split(" ").join("_")
@user.send("#{tag_type}_tags", tags)
@user.save
end

Then /^"([^\"]*)" should have "([^\"]*)" as "([^\"]*)"$/ do |user, code, attribute|
  user += "@echologic.org" unless user =~ /.*@.*\..{2,3}/
  @user = User.find_by_email(user)
  key = EnumKey.find_by_code(code)
  assert @user.send(attribute.to_sym).eql?(key)
end

Then /^an "([^\"]*)" email should be sent to "([^\"]*)"$/ do |email_type, email_address|
  assert !ActionMailer::Base.deliveries.empty?
  assert_equal 1, ActionMailer::Base.deliveries.length
  email = ActionMailer::Base.deliveries.first
  assert_equal [email_address], email.to
  assert_match /#{email_type}/, email.subject
end


Then /^"([^\"]*)" should have "([^\"]*)" as password$/ do |name, password|
  user = Profile.find_by_full_name(name).user
  u_session = UserSession.new(:email => user.email, :password => password)
  assert u_session.save
end

Then /^"([^\"]*)" should have a profile$/ do |name|
  profile = Profile.find_by_full_name(name)
  assert !profile.nil?
end

Then /^I should have "([^\"]*)" as ([^\"]*)$/ do |value, attr|
  assert @user.reload.send(attr).eql? value
end

Then /^I should be inactive$/ do 
  assert !@user.reload.active
end
