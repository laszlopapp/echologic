Given /^a proposal without echos$/ do
  @proposal = Proposal.first
  @proposal.user_echos.destroy_all
end

Then /^the proposal should have one echo$/ do
  @proposal.reload
  @proposal.echo.supporter_count.should >= 1
end

Then /^the proposal should have one visitor but no echos$/ do
  @proposal.reload
  @proposal.echo.visitor_count.should >= 1
end


Given /^I gave an echo already to a proposal$/ do
  @proposal = Proposal.first
  @proposal.user_echos.destroy_all
  @proposal.supported_by!(@user)
  @user.find_or_create_subscription_for(@proposal)
end

Then /^the proposal should have no more echo$/ do
  @proposal.reload
  @proposal.echo.supporter_count.should == 0
end

Then /^the proposal should have "([^\"]*)" as follower$/ do |name|
  @proposal.reload
  assert @proposal.followed_by?(@user)
end

Then /^the proposal should not have "([^\"]*)" as follower$/ do |name|
  @proposal.reload
  assert !@user.follows?(@proposal)
end