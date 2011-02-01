Given /^there are no questions$/ do
  Question.destroy_all
end

Then /^there should be no questions$/ do
  Question.count.should == 0
end

Then /^there should be one question$/ do
  Question.count.should == 1
end

When /^I choose the first Question$/ do
  response.should have_selector("li.question a") do |selector|
    @question = Question.find(URI.parse(selector.first['href']).path.match(/\d+/)[0].to_i)
    visit selector.first['href']
  end
end

When /^I choose the second Question$/ do
  response.should have_selector("li.question a") do |selector|
    if question_id = URI.parse(selector[1]['href']).path.match(/\d+/)[0].to_i
      @second_question = Question.find(question_id)
      visit selector.first['href']
    else
      raise 'there is no second question dude... this test does not work'
    end
  end
end

When /^I choose the "([^\"]*)" Question$/ do |name|
  response.should have_selector("li.question") do |selector|
    selector.each do |question|
      if name.eql?(question.at_css("span.name").inner_text.strip)
        @question = Question.find(URI.parse(question.at_css("a")['href']).path.match(/\d+/)[0].to_i)
        visit question.at_css("a")['href']
      end
    end
  end
end

When /^I choose the "([^\"]*)" Proposal$/ do |name|
  response.should have_selector("li.proposal") do |selector|
    selector.each do |proposal|
      if name.eql?(proposal.at_css("a.proposal_link").inner_text.strip)
        @proposal = Proposal.find(URI.parse(proposal.at_css("a")['href']).path.match(/\d+/)[0].to_i)
        visit proposal.at_css("a")['href']
      end
    end
  end
end

When /^I choose the "([^\"]*)" Improvement$/ do |name|
  response.should have_selector("li.improvement") do |selector|
    selector.each do |improvement|
      if name.eql?(improvement.at_css("a.improvement_link").inner_text.strip)
        @improvement = Improvement.find(URI.parse(improvement.at_css("a")['href']).path.match(/\d+/)[0].to_i)
        visit improvement.at_css("a")['href']
      end
    end
  end
end

Then /^I should see an error message$/i do
  Then 'I should see "error"'
end

Given /^there is the first question$/i do
  @question = Question.last
end

Given /^there is the second question$/i do
  @question = Question.first
end

Given /^there is a question$/ do
  @question = Question.first
end

Given /^there is a question "([^\"]*)"$/ do |id| # not in use right now
  @question = Question.find(id)
end

Given /^there is a question i have created$/ do # not in use right now
   @question = Question.find_by_creator_id(@user.id)
end

Given /^the question was not published yet$/ do
  @question.editorial_state = StatementState["new"]
  @question.statement.save
end

Given /^the question has proposals$/ do
  @question.reload
  @question.children.proposals.count.should >= 1
end

Given /^the question has "([^\"]*)" for tags$/i do |tags|
  @question.topic_tags = tags
  @question.statement.save
end

Given /^the question has no proposals$/ do
  @question.children.proposals.destroy_all
end

When /^I follow the create proposal link$/ do
  # Todo: Yet we still don't know how the create proposal link will once look
  When 'I follow the "Create proposal" link within the "children" list'
end

Then /^the question should have one proposal$/ do
  @question.reload
  @question.children.proposals.count.should >= 1
end

Then /^the question "([^\"]*)" should have "([^\"]*)" as tags$/ do |title, tags|
  tags = tags.split(',').map{|t| t.strip}
  @question = StatementNode.search_statement_nodes(:type => "Question",
                                                   :search_term => title,
                                                   :language_ids => [Language["en"]],
                                                   :show_unpublished => true).first
  res = @question.topic_tags - tags
  res.should == []
end

Then /^the second question must be more recent than the first question$/ do
  @question.created_at < @second_question.created_at
end

# Is it okay to give a condition in a 'Given' step?
Given /^the question has at least one proposal$/ do
  @question.reload
  @question.children.proposals.count.should >= 1
  @proposal = @question.children.proposals.first
end

Then /^the proposal should have one improvement$/ do
  @proposal.reload
  @proposal.children.improvements.count.should >= 1
end

Then /^I should not see the create proposal link$/ do
#  Then 'I should not see the "Create proposal" link within the "children" container'
  Then 'I should not see the "Create proposal" link'
end

Given /^a "([^\"]*)" question in "([^\"]*)"$/ do |state, category|
  state = StatementState[state.downcase]
  @question = Question.new_instance(:editorial_state => state, :creator => @user)
  @question.add_statement_document({:title => "Am I a new statement?",
                                      :text => "I wonder what i really am! Maybe a statement? Or even a question?",
                                      :author => @user,
                                      :current => 1,
                                      :language_id => @user.sorted_spoken_language_ids.first,
                                      :action_id => StatementAction["created"].id,
                                      :original_language_id => @user.sorted_spoken_language_ids.first})
  @question.topic_tags << category
  @question.save!
end

Then /^the question should be published$/ do
  @question.reload
  assert @question.state.eql?(StatementState["published"])
end

Then /^I should see the questions title$/ do
  Then 'I should see "'+@question.document_in_preferred_language([Language["en"].id, Language["de"].id]).title+'"'
end

Given /^there is a proposal I have created$/ do
  @proposal = Proposal.find_by_creator_id(@user.id)
end

Given /^there is a proposal$/ do
  @proposal = Question.all(:joins => :statement, :conditions => "statements.editorial_state_id = #{StatementState['published'].id}").last.children.proposals.first
end

Given /^the proposal was not published yet$/ do
  @proposal.editorial_state = StatementState["new"]
  @proposal.statement.save
end

Given /^I have "([^\"]*)" as decision making tags$/ do |tags|
  @user.decision_making_tags << tags
  @user.save
end

Then /^the questions title should be "([^\"]*)"$/ do |title|
  @question.document.title.should == title
end


Then /^I should see the proposals data$/ do
  Then 'I should see "'+@proposal.document_in_preferred_language([Language["en"].id,Language["de"].id]).title+'"'
  Then 'I should see "'+@proposal.document_in_preferred_language([Language["en"].id,Language["de"].id]).text+'"'
end

Then /^I should see no proposals$/ do
  assert_have_no_selector("li.question")
end

Then /^I should be a subscriber from "([^\"]*)"$/ do |question|
  @question = StatementNode.search_statement_nodes(:type => "Question",
                                                   :search_term => question,
                                                   :language_ids => [Language["en"]]).first
  assert(@question.followed_by?(@user))
end

Then /^"([^\"]*)" should have a "([^\"]*)" event$/ do |question, op_type|
  @question = StatementNode.search_statement_nodes(:type => "Question",
                                                   :search_term => question,
                                                   :language_ids => [Language["en"]]).first
  event = Event.find_by_subscribeable_id(@question.id)
  assert !event.nil?
  assert event.operation.eql?(op_type)
end

Then /^the ([^\"]*) should have ([^\"]*) siblings in session$/ do |statement_type, siblings_number|
  type = statement_type.split(" ").map(&:downcase).join("_").classify.constantize.name_for_siblings
  response.should have_selector("#statements div.#{type}") do |selector|
    statement = selector.first
    siblings = eval(statement.get_attribute("data-siblings"))
    assert siblings.select{|s|s.is_a?(Numeric)}.length - 1 == siblings_number.to_i
  end
end

Then /^there should be a "([^\"]*)" breadcrumb$/ do |title|
  response.should have_selector("#breadcrumbs span.statement") do |selector|
    result = false
    selector.each do |breadcrumb|
      if title.eql?(breadcrumb.inner_text.strip)
        result = true
        break
      end
    end
    assert result
  end
end
