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
  response.should have_selector("li.question") do |selector|
    selector.each do |question|
      if name.eql?(question.at_css("a.proposal_link").inner_text.strip)
        @question = Proposal.find(URI.parse(question.at_css("a")['href']).path.match(/\/proposals\/\d+/)[0].split('/')[2].to_i)
        visit question.at_css("a")['href']
      end
    end
  end
end

When /^I choose the "([^\"]*)" Improvement Proposal$/ do |name|
  response.should have_selector("li.proposal") do |selector|
    selector.each do |question|
      if name.eql?(question.at_css("a.improvement_proposal_link").inner_text.strip)
        @question = ImprovementProposal.find(URI.parse(question.at_css("a")['href']).path.match(/\/improvement_proposals\/\d+/)[0].split('/')[2].to_i)
        visit question.at_css("a")['href']
      end
    end
  end
end

Then /^I should see an error message$/i do
  pending
  Then "I should see a \"error box\""
end

Given /^there is the first question$/i do 
  @question = Question.last
end

Given /^there is the second question$/i do 
  @question = Question.first
end

Given /^there is a question "([^\"]*)"$/ do |id| # not in use right now
  @question = Question.find(id)
end

Given /^the question has proposals$/ do
  @question.reload
  @question.children.proposals.count.should >= 1
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

Then /^the second question must be more recent than the first question$/ do
  @question.created_at < @second_question.created_at
end

# Is it okay to give a condition in a 'Given' step?
Given /^the question has at least on proposal$/ do
  @question.reload
  @question.children.proposals.count.should >= 1
  @proposal = @question.children.proposals.first
end

Then /^the proposal should have one improvement proposal$/ do
  @proposal.reload
  @proposal.children.improvement_proposals.count.should >= 1
end

Then /^I should not see the create proposal link$/ do
#  Then 'I should not see the "Create proposal" link within the "children" container'
  Then 'I should not see the "Create proposal" link'
end

Given /^a "([^\"]*)" question in "([^\"]*)"$/ do |state, category|
  case state
    when "new"
      state = 0
    when "published"
      state = 1
  end
  @category = Tag.find_by_value(category)
  @question = Question.new(:state => state, :creator => @user)
  @question.tao_tags << TaoTag.new(:tag_id => @category.id, :tao_type => StatementNode.name, :context_id => EnumKey.find_by_code("topic"))
  @question.create_statement(:original_language_id => @user.language_keys.first)
  @question.add_statement_document!(:title => "Am I a new statement?", :text => "I wonder what i really am! Maybe a statement? Or even a question?", :author => @user, :language_id => @user.language_keys.first)
  @question.save!
end

Then /^the question should be published$/ do
  @question.reload
  @question.state.should == 1
end

Then /^I should see the questions title$/ do 
  Then 'I should see "'+@question.translated_document([StatementDocument.languages("en").first.id, StatementDocument.languages("de").first.id]).title+'"'
end

Given /^there is a proposal I have created$/ do
  @proposal = Proposal.find_by_creator_id(@user.id)
end

Given /^there is a proposal$/ do
  @proposal = Question.find_all_by_state(1).last.children.proposals.first
end

Then /^the questions title should be "([^\"]*)"$/ do |title|
  @question.document.title.should == title
end


Then /^I should see the proposals data$/ do
  Then 'I should see "'+@proposal.translated_document([StatementDocument.languages("en").first.id,StatementDocument.languages("de").first.id]).title+'"'
  Then 'I should see "'+@proposal.translated_document([StatementDocument.languages("en").first.id,StatementDocument.languages("de").first.id]).text+'"'
end

Then /^I should see no proposals$/ do
  assert_have_no_selector("li.question")
end
  