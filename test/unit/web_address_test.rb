require 'test_helper'

class WebAddressTest < ActiveSupport::TestCase
  
  # Web profiles mustn't be saved empty.
  def test_no_empty_saving
    w = WebAddress.new
    assert !w.save
  end

  # Web profile model has to provide which profiles are available.
  def test_sorts
    assert_kind_of Array, WebAddress.sorts
  end

  # Web profiles has to belong to a user.
  def test_presence_of_user
    assert_kind_of User, web_addresses(:joe_twitter).user
  end

end
