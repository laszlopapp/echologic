require 'test_helper'

class UserTest < ActiveSupport::TestCase


  context "a user" do
    setup { @user = User.new }
    subject { @user }

    should_have_many :web_addresses, :memberships, :spoken_languages, :reports
    should_have_many :tao_tags
    should_have_many :tags
    should_have_one :profile

    context "being saved" do
      setup do
        #TODO - replace this by proper creation of an new user
        @user = User.first
      end

      context "with spoken languages" do
        setup do
          # TODO - replace this by proper creation of spoken languages associated to this user
        end

        should "return spoken languages as an array of keys (EnumKey)" do
          # TODO - this will only work when fixtures do not change. see todos above
          assert_equal @user.spoken_language_ids, @user.spoken_languages.collect{|sl| sl.language.id}
        end

      end

    end
  end



  # 1. Users should have associations to:
  #     - Web profiles
  #     - Concernments
  #     - Tags
  #     - Memberships
  def test_associations
    @user = users(:joe)
    assert_not_nil @user.web_addresses
    assert_not_nil @user.tao_tags
    assert_not_nil @user.tags
    assert_not_nil @user.memberships
  end

  # 1. Roles can be assigned to users.
  # 2. The users roles may be accessed.
  def test_role_associations
    @user = users(:joe)
    assert_respond_to @user, :has_role?
    assert @user.has_role!(:admin)
  end

  # 1. Users must not be saved empty.
  def test_no_empty_saving
    assert !User.new.save
  end


end
