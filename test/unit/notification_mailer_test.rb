require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  def test_approval_email
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = NotificationMailer.deliver_approval!(statement_node, statement_document)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [statement_document.author.email], email.to
    assert_equal "Your Improvement Proposal was Approved!", email.subject
    assert_match /#{statement_document.author.full_name}/, email.encoded
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.id}/, email.encoded
  end
  
  def test_supporters_approval_email
    users = [users(:user),users(:joe),users(:ben)]
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = NotificationMailer.deliver_supporters_approval!(statement_node, statement_document, users)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal users.map{|u|u.email}, email.bcc
    assert_equal "You have the privilege to incorporate a Improvement Proposal!", email.subject
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.id}/, email.encoded
  end
  
  def test_approval_reminder_email
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = NotificationMailer.deliver_approval_reminder!(statement_node, statement_document)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [statement_document.author.email], email.to
    assert_equal "Improvement Proposal Approval Reminder!", email.subject
    assert_match /#{statement_document.author.full_name}/, email.encoded
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.id}/, email.encoded
  end
  
  def test_supporters_approval_reminder_email
    users = [users(:user),users(:joe),users(:ben)]
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = NotificationMailer.deliver_supporters_approval_reminder!(statement_node, statement_document, users)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal users.map{|u|u.email}, email.bcc
    assert_equal "Improvement Proposal Approval Reminder!", email.subject
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.id}/, email.encoded
  end
  
  def test_passed_email
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = NotificationMailer.deliver_passed!(statement_document)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [statement_document.author.email], email.to
    assert_equal "Improvement Proposal Approval Passed!", email.subject
    assert_match /#{statement_document.author.full_name}/, email.encoded
    assert_match /#{statement_document.title}/, email.encoded
  end
  
  def test_supporters_passed_email
    users = [users(:user),users(:joe),users(:ben)]
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = NotificationMailer.deliver_supporters_passed!(statement_document, users)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal users.map{|u|u.email}, email.bcc
    assert_equal "Improvement Proposal Approval Passed!", email.subject
    assert_match /#{statement_document.title}/, email.encoded
  end
  
  def test_incorporated_email
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = NotificationMailer.deliver_incorporated!(statement_node, statement_document)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [statement_document.author.email], email.to
    assert_equal "Your Improvement Proposal was successfully incorporated!", email.subject
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.parent.id}/, email.encoded
  end
  
end