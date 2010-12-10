Given /^there are no discussions$/ do
  Discussion.destroy_all
end

Then /^there should be no discussions$/ do
  Discussion.count.should == 0
end

Then /^there should be one discussion$/ do
  Discussion.count.should == 1
end

When /^I choose the first Discussion$/ do
  response.should have_selector("li.discussion a") do |selector|
    @discussion = Discussion.find(URI.parse(selector.first['href']).path.match(/\d+/)[0].to_i)
    visit selector.first['href']
  end
end

When /^I choose the second Discussion$/ do
  response.should have_selector("li.discussion a") do |selector|
    if discussion_id = URI.parse(selector[1]['href']).path.match(/\d+/)[0].to_i
      @second_discussion = Discussion.find(discussion_id)
      visit selector.first['href']
    else
      raise 'there is no second discussion dude... this test does not work'
    end
  end
end

When /^I choose the "([^\"]*)" Discussion$/ do |name|
  response.should have_selector("li.discussion") do |selector|
    selector.each do |discussion|
      if name.eql?(discussion.at_css("span.name").inner_text.strip)
        @discussion = Discussion.find(URI.parse(discussion.at_css("a")['href']).path.match(/\d+/)[0].to_i)
        visit discussion.at_css("a")['href']
      end
    end
  end
end

When /^I choose the "([^\"]*)" Proposal$/ do |name|
  response.should have_selector("li.discussion") do |selector|
    selector.each do |proposal|
      if name.eql?(proposal.at_css("a.proposal_link").inner_text.strip)
        @proposal = Proposal.find(URI.parse(proposal.at_css("a")['href']).path.match(/\d+/)[0].to_i)
        visit proposal.at_css("a")['href']
      end
    end
  end
end

When /^I choose the "([^\"]*)" Improvement Proposal$/ do |name|
  response.should have_selector("li.proposal") do |selector|
    selector.each do |improvement_proposal|
      if name.eql?(improvement_proposal.at_css("a.improvement_proposal_link").inner_text.strip)
        @improvement_proposal = ImprovementProposal.find(URI.parse(improvement_proposal.at_css("a")['href']).path.match(/\d+/)[0].to_i)
        visit improvement_proposal.at_css("a")['href']
      end
    end
  end
end

Then /^I should see an error message$/i do
  Then 'I should see "error"'
end

Given /^there is the first discussion$/i do
  @discussion = Discussion.last
end

Given /^there is the second discussion$/i do
  @discussion = Discussion.first
end

Given /^there is a discussion "([^\"]*)"$/ do |id| # not in use right now
  @discussion = Discussion.find(id)
end

Given /^there is a discussion i have created$/ do # not in use right now
   @discussion = Discussion.find_by_creator_id(@user.id)
end

Given /^the discussion was not published yet$/ do
  @discussion.editorial_state = StatementState["new"]
  @discussion.save
end

Given /^the discussion has proposals$/ do
  @discussion.reload
  @discussion.children.proposals.count.should >= 1
end

Given /^the discussion has "([^\"]*)" for tags$/i do |tags|
  @discussion.topic_tags = tags
  @discussion.save
end

Given /^the discussion has no proposals$/ do
  @discussion.children.proposals.destroy_all
end

When /^I follow the create proposal link$/ do
  # Todo: Yet we still don't know how the create proposal link will once look
  When 'I follow the "Create proposal" link within the "children" list'
end

Then /^the discussion should have one proposal$/ do
  @discussion.reload
  @discussion.children.proposals.count.should >= 1
end

Then /^the discussion "([^\"]*)" should have "([^\"]*)" as tags$/ do |title, tags|
  tags = tags.split(',').map{|t| t.strip}
  @discussion = StatementNode.search_statement_nodes(:type => "Discussion",
                                                   :search_term => title,
                                                   :language_ids => [Language["en"]],
                                                   :show_unpublished => true).first
  res = @discussion.topic_tags - tags
  res.should == []
end

Then /^the second discussion must be more recent than the first discussion$/ do
  @discussion.created_at < @second_discussion.created_at
end

# Is it okay to give a condition in a 'Given' step?
Given /^the discussion has at least on proposal$/ do
  @discussion.reload
  @discussion.children.proposals.count.should >= 1
  @proposal = @discussion.children.proposals.first
end

Then /^the proposal should have one improvement proposal$/ do
  @proposal.reload
  @proposal.children.improvement_proposals.count.should >= 1
end

Then /^I should not see the create proposal link$/ do
#  Then 'I should not see the "Create proposal" link within the "children" container'
  Then 'I should not see the "Create proposal" link'
end

Given /^a "([^\"]*)" discussion in "([^\"]*)"$/ do |state, category|
  state = StatementState[state.downcase]
  @discussion = Discussion.new(:editorial_state => state, :creator => @user)
  @discussion.add_statement_document({:title => "Am I a new statement?",
                                      :text => "I wonder what i really am! Maybe a statement? Or even a discussion?",
                                      :author => @user,
                                      :current => 1,
                                      :language_id => @user.sorted_spoken_language_ids.first,
                                      :action_id => StatementAction["created"].id,
                                      :original_language_id => @user.sorted_spoken_language_ids.first})
  @discussion.topic_tags << category
  @discussion.save!
end

Then /^the discussion should be published$/ do
  @discussion.reload
  assert @discussion.state.eql?(StatementState["published"])
end

Then /^I should see the discussions title$/ do
  Then 'I should see "'+@discussion.document_in_preferred_language([Language["en"].id, Language["de"].id]).title+'"'
end

Given /^there is a proposal I have created$/ do
  @proposal = Proposal.find_by_creator_id(@user.id)
end

Given /^there is a proposal$/ do
  @proposal = Discussion.find_all_by_editorial_state_id(StatementState['published'].id).last.children.proposals.first
end

Given /^the proposal was not published yet$/ do
  @proposal.editorial_state = StatementState["new"]
  @proposal.save
end

Given /^I have "([^\"]*)" as decision making tags$/ do |tags|
  @user.decision_making_tags << tags
  @user.save
end

Then /^the discussions title should be "([^\"]*)"$/ do |title|
  @discussion.document.title.should == title
end


Then /^I should see the proposals data$/ do
  Then 'I should see "'+@proposal.document_in_preferred_language([Language["en"].id,Language["de"].id]).title+'"'
  Then 'I should see "'+@proposal.document_in_preferred_language([Language["en"].id,Language["de"].id]).text+'"'
end

Then /^I should see no proposals$/ do
  assert_have_no_selector("li.discussion")
end

Then /^I should be a subscriber from "([^\"]*)"$/ do |discussion|
  @discussion = StatementNode.search_statement_nodes(:type => "Discussion",
                                                   :search_term => discussion,
                                                   :language_ids => [Language["en"]]).first
  assert(@discussion.followed_by?(@user))
end

Then /^"([^\"]*)" should have a "([^\"]*)" event$/ do |discussion, op_type|
  @discussion = StatementNode.search_statement_nodes(:type => "Discussion",
                                                   :search_term => discussion,
                                                   :language_ids => [Language["en"]]).first
  event = Event.find_by_subscribeable_id(@discussion.id)
  assert !event.nil?
  assert event.operation.eql?(op_type)
end
