require 'test_helper'

class ActivityTrackingMailerTest < ActionMailer::TestCase
  include StatementHelper
  def test_activity_tracking_email_question
    user = users(:user)
    question_event = events(:event_test_question)
    question_events = [question_event]

    tags = {'#echonomyjam' => 1,'user' => 2}
    events = []
    title = JSON.parse(question_event.event)['question']['statement']['statement_documents'][0]['title']
    # Send the email, then test that it got queued
    email = ActivityTrackingMailer.deliver_activity_tracking_email!(user,question_events,tags,events)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "Activity Tracking", email.subject
    assert_match /Activity Tracking/, email.encoded
    assert_match /New Debates from last week: 1/, email.encoded
    assert_match /#{title}/, email.encoded
    assert_match /#{question_event.subscribeable.id}/, email.encoded
    assert_match /New Tags:/, email.encoded
    assert_match /user/, email.encoded
    assert_match /(2)/, email.encoded
  end

  def test_activity_tracking_email_proposal
    user = users(:user)
    question_events = []
    tags = {}
    proposal_event = events(:event_second_proposal)
    parent_id = JSON.parse(proposal_event.event)['proposal']['parent_id']
    title = JSON.parse(proposal_event.event)['proposal']['statement']['statement_documents'][0]['title']
    events = [proposal_event]
    # Send the email, then test that it got queued
    email = ActivityTrackingMailer.deliver_activity_tracking_email!(user,question_events,tags,events)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "Activity Tracking", email.subject
    assert_match /Activity Tracking/, email.encoded
    assert_match /#{Question.find(parent_id).document_in_preferred_language(EnumKey.find_by_code("en")).title}/, email.encoded
    assert_match /#{proposal_event.subscribeable.id}/, email.encoded
    assert_match /#{proposal_event.subscribeable.parent.id}/, email.encoded
    assert_match /#{title}/, email.encoded
  end

  def test_activity_tracking_email_improvement_proposal
    user = users(:user)
    question_events = []
    tags = {}
    impro_proposal_event = events(:event_first_impro_proposal)
    parent_id = JSON.parse(impro_proposal_event.event)['improvement_proposal']['parent_id']
    root_id = JSON.parse(impro_proposal_event.event)['improvement_proposal']['root_id']
    title = JSON.parse(impro_proposal_event.event)['improvement_proposal']['statement']['statement_documents'][0]['title']
    events = [impro_proposal_event]
    # Send the email, then test that it got queued
    email = ActivityTrackingMailer.deliver_activity_tracking_email!(user,question_events,tags,events)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "Activity Tracking", email.subject
    assert_match /Activity Tracking/, email.encoded
    assert_match /#{Proposal.find(parent_id).document_in_preferred_language(EnumKey.find_by_code("en")).title}/, email.encoded
    assert_match /#{Question.find(root_id).document_in_preferred_language(EnumKey.find_by_code("en")).title}/, email.encoded
    assert_match /#{impro_proposal_event.subscribeable.id}/, email.encoded
    assert_match /#{impro_proposal_event.subscribeable.parent.id}/, email.encoded
    assert_match /#{impro_proposal_event.subscribeable.root.id}/, email.encoded
    assert_match /#{title}/, email.encoded
  end

end