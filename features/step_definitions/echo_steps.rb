Given /^a proposal without echos$/ do
  @proposal = Proposal.first
  @proposal.user_echos.destroy_all
end

Then /^the proposal should have one echo$/ do
  @proposal.reload
  i = UserEcho.count(:conditions => ["echo_id = ? and supported = 1", @proposal.echo.id])
  i >= 1
end

Then /^the proposal should have one visitor but no echos$/ do
  @proposal.reload
  @proposal.echo.visitor_count.should >= 1
end


Given /^I gave an echo already to a proposal$/ do
  @proposal = Proposal.first
  @proposal.user_echos.destroy_all
  ed = @proposal.supported_by!(@user)
  @proposal.add_subscriber(@user)
end

Then /^the proposal should have no more echo$/ do
  @proposal = Proposal.first
  i = UserEcho.count(:conditions => ["echo_id = ? and supported = 1", @proposal.echo.id])
  i == 0
end

Then /^the proposal should have "([^\"]*)" as follower$/ do |name|
  @proposal.reload
  assert @proposal.followed_by?(@user)
end

Then /^the proposal should not have "([^\"]*)" as follower$/ do |name|
  @proposal.reload
  assert !@user.follows?(@proposal)
end