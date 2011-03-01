require 'test_helper'

class DraftingMailerTest < ActionMailer::TestCase
  def test_approval_email
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = DraftingMailer.deliver_approval!(DraftingService.instance.prepare_mail(statement_node))
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [statement_document.author.email], email.to
    assert_equal "Your addition can now be incorporated", email.subject
    assert_match /#{statement_document.author.full_name}/, email.encoded
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.parent.id}/, email.encoded
  end

  def test_supporters_approval_email
    users = [users(:user),users(:joe),users(:ben)]
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = DraftingMailer.deliver_supporters_approval!(users, DraftingService.instance.prepare_mail(statement_node))
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal users.map{|u|u.email}, email.bcc
    assert_equal "An addition you support can now be incorporated", email.subject
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.parent.id}/, email.encoded
  end

  def test_approval_reminder_email
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = DraftingMailer.deliver_approval_reminder!(DraftingService.instance.prepare_mail(statement_node))
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [statement_document.author.email], email.to
    assert_equal "Reminder! - Time is running out to incorporate your winner addition", email.subject
    assert_match /#{statement_document.author.full_name}/, email.encoded
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.parent.id}/, email.encoded
  end

  def test_supporters_approval_reminder_email
    users = [users(:user),users(:joe),users(:ben)]
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = DraftingMailer.deliver_supporters_approval_reminder!(users, DraftingService.instance.prepare_mail(statement_node))
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal users.map{|u|u.email}, email.bcc
    assert_equal "Last Reminder! - Time is running out to incorporate a winner addition", email.subject
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.parent.id}/, email.encoded
  end

  def test_passed_email
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = DraftingMailer.deliver_passed!(DraftingService.instance.prepare_mail(statement_node))
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [statement_document.author.email], email.to
    assert_equal "Passed to incorporate your winner addition", email.subject
    assert_match /#{statement_document.author.full_name}/, email.encoded
    assert_match /#{statement_document.title}/, email.encoded
  end

  def test_supporters_passed_email
    users = [users(:user),users(:joe),users(:ben)]
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = DraftingMailer.deliver_supporters_passed!(users, DraftingService.instance.prepare_mail(statement_node))
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal users.map{|u|u.email}, email.bcc
    assert_equal "Passed to incorporate a winner addition", email.subject
    assert_match /#{statement_document.title}/, email.encoded
  end

  def test_incorporated_email
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = DraftingMailer.deliver_incorporated!(DraftingService.instance.prepare_mail(statement_node))
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [statement_node.parent.document_in_drafting_language.author.email], email.to
    assert_equal "Thank you for improving the proposal", email.subject
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.parent.id}/, email.encoded
  end

  def test_approval_notification_email
    users = [users(:user),users(:joe),users(:ben)]
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-impro-proposal-doc-english')
    # Send the email, then test that it got queued
    email = DraftingMailer.deliver_approval_notification!(users, DraftingService.instance.prepare_mail(statement_node))
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal users.map{|u|u.email}, email.bcc
    assert_equal "A proposal you support is about to be improved", email.subject
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.parent.id}/, email.encoded
  end

  def test_incorporation_notification_email
    users = [users(:user),users(:joe),users(:ben)]
    statement_node = statement_nodes('first-impro-proposal')
    statement_document = statement_documents('first-proposal-doc-english')
    # Send the email, then test that it got queued
    email = DraftingMailer.deliver_incorporation_notification!(users, DraftingService.instance.prepare_mail(statement_node))
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal users.map{|u|u.email}, email.bcc
    assert_equal "A proposal you support has been improved", email.subject
    assert_match /#{statement_document.title}/, email.encoded
    assert_match /#{statement_node.parent.id}/, email.encoded
  end

end