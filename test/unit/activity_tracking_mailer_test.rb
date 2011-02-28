require 'test_helper'

class ActivityTrackingMailerTest < ActionMailer::TestCase

  def test_activity_tracking_mail_question
    user = users(:user)
    question_event = JSON.parse(events(:event_test_question).event)
    question_events = [question_event]

    tags = {'#echonomyjam' => 1,'user' => 2}
    events = {}
    id = question_event['id']
    en = Language['en']
    title = question_event['documents'][en.id]
    # Send the email, then test that it got queued
    email = ActivityTrackingMailer.deliver_activity_tracking_mail!(user,question_events,tags,events)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "echo - Activity Notifications", email.subject
    assert_match /echo - Activity Notifications/, email.encoded
    assert_match /1 new question/, email.encoded
    assert_match /#{title}/, email.encoded
    assert_match /#{id}/, email.encoded
    assert_match /They are related to the following topics:/, email.encoded
    assert_match /user/, email.encoded
    assert_match /(2)/, email.encoded
  end

  def test_activity_tracking_mail_proposal
    user = users(:user)
    question_events = []
    tags = {}
    proposal_event = JSON.parse(events(:event_second_proposal).event)
    id = proposal_event['id']
    parent_id = proposal_event['parent_id']
    en = Language['en']
    title = proposal_event['documents'][en.id]
    events = {proposal_event['level'] => {
              proposal_event['parent_id'] => {
              proposal_event['type'] => {
              proposal_event['operation'] => [proposal_event]}}} }
    # Send the email, then test that it got queued
    email = ActivityTrackingMailer.deliver_activity_tracking_mail!(user,question_events,tags,events)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "echo - Activity Notifications", email.subject
    assert_match /echo - Activity Notifications/, email.encoded
    assert_match /#{Question.find(parent_id).document_in_preferred_language(Language['en']).title}/, email.encoded
    assert_match /#{id}/, email.encoded
    assert_match /#{title}/, email.encoded
  end

  def test_activity_tracking_mail_improvement
    user = users(:user)
    question_events = []
    tags = {}
    impro_proposal_event = JSON.parse(events(:event_first_impro_proposal).event)
    id = impro_proposal_event['id']
    parent_id = impro_proposal_event['parent_id']
    en = Language['en']
    title = impro_proposal_event['documents'][en.id]
    events = {impro_proposal_event['level'] => {
              impro_proposal_event['parent_id'] => {
              impro_proposal_event['type'] => {
              impro_proposal_event['operation'] => [impro_proposal_event]}}} }
    # Send the email, then test that it got queued
    email = ActivityTrackingMailer.deliver_activity_tracking_mail!(user,question_events,tags,events)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "echo - Activity Notifications", email.subject
    assert_match /echo - Activity Notifications/, email.encoded
    assert_match /#{Proposal.find(parent_id).document_in_preferred_language(Language['en']).title}/, email.encoded
    assert_match /#{id}/, email.encoded
    assert_match /#{title}/, email.encoded
  end

end