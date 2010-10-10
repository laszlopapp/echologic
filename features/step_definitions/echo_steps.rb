Given /^a proposal without echos$/ do
  @proposal = Proposal.first
  @proposal.user_echos.destroy_all
end

Given /^I have the "([^\"]*)" proposal$/ do |title|
  @proposal = StatementNode.search_statement_nodes(:type => "Proposal",
                                                   :search_term => title,
                                                   :language_ids => [Language["en"]]).first
end


Then /^the proposal should have one echo$/ do
  @proposal.reload
  i = UserEcho.count(:conditions => ["echo_id = ? and supported = 1", @proposal.echo.id])
  i >= 1
end

Given /^the proposal has no supporters$/ do
  @proposal.reload
  UserEcho.destroy_all("echo_id = #{@proposal.echo.id} and supported = 1") if @proposal.echo
end

Then /^the proposal should have ([^\"]*) supporters$/ do |supporter_count|
  @proposal.reload
  user_echos = UserEcho.count(:conditions => ["echo_id = ? and supported = 1", @proposal.echo.id])
  assert supporter_count.to_i == user_echos
  assert supporter_count.to_i == @proposal.echo.supporter_count
end

Then /^the proposal should have ([^\"]*) visitors$/ do |visitor_count|
  user_echos = UserEcho.count(:conditions => ["echo_id = ? and visited = 1", @proposal.echo.id])
  assert visitor_count.to_i == user_echos
  assert visitor_count.to_i == @proposal.echo.visitor_count
end

Then /^the proposal should have one visitor but no echos$/ do
  @proposal.reload
  @proposal.echo.visitor_count.should >= 1
end


Given /^I gave an echo already to a proposal$/ do
  @proposal = Proposal.first
  @proposal.user_echos.destroy_all
  ed = @proposal.supported!(@user)
end

Then /^the proposal should have no more echo$/ do
  @proposal = Proposal.first
  i = UserEcho.count(:conditions => ["echo_id = ? and supported = 1", @proposal.echo.id])
  i == 0
end

Then /^the proposal should have "([^\"]*)" as follower$/ do |name|
  assert Delayed::Job.last.name[9..22] == "add_subscriber"
#  user = Profile.find_by_first_name(name).user
#  @proposal.reload
#  assert user.follows?(@proposal)
end

Then /^the proposal should not have "([^\"]*)" as follower$/ do |name|
  assert Delayed::Job.last.name[9..25] == "remove_subscriber"
#  user = Profile.find_by_first_name(name).user
#  @proposal.reload
#  assert !user.follows?(@proposal)
end

Then /^I am supporter of the proposal$/ do
  @proposal.reload
  assert @proposal.supported?(@user)
end

Then /^I am supporter of the improvement proposal$/ do
  @improvement_proposal.reload
  assert @improvement_proposal.supported?(@user)
end

Then /^I am not supporter of the proposal$/ do
  @proposal.reload
  assert !@proposal.supported?(@user)
end

Then /^I am not supporter of the improvement proposal$/ do
  @improvement_proposal.reload
  assert !@improvement_proposal.supported?(@user)
end

Then /^the proposal should have "([^\"]*)" as supporters$/ do |users|
  @proposal.reload
  users.split(",").each do |user_name|
    assert @proposal.supported?(Profile.find_by_first_name(user_name.strip).user)
  end
end

Then /^the proposal should have "([^\"]*)" as visitors$/ do |users|
  @proposal.reload
  users.split(",").each do |user_name|
    assert @proposal.visited?(Profile.find_by_first_name(user_name.strip).user)
  end
end