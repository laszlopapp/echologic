Given /^the minimum number of votes is ([^\"]*)$/ do |min_votes|
  DraftingService.min_votes = min_votes.to_i
end

Given /^the proposal has an ([^\"]*) child$/ do |state|
  @proposal.reload
  imp = @proposal.children.first
  imp.drafting_state = state
  imp.save
end

Then /^the state of the improvement proposal must be "([^\"]*)"$/ do |state|
  @improvement_proposal.reload
  assert @improvement_proposal.send("#{state}?")
end

Then /^the proposal has ([^\"]*) children$/ do |state|
  state = state.split(" ")
  @proposal.reload
  if state[0].eql?("no")
    assert @proposal.send("#{state[1]}_children").empty?
  else
    assert !@proposal.send("#{state[0]}_children").empty?
  end
end

