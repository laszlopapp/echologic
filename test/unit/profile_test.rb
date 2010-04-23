require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  fixtures :profiles

  context "Profile" do
    setup {}
    context "given a search request" do
      setup {
        @profiles = Profile.search_profiles("", "")
        @ben_profile = profiles(:ben_profile)
        @user_profile = profiles(:user_profile)
      }
      should "be ordered by completeness and by name" do
        assert_equal @profiles.first, @ben_profile
        @ben_profile.completeness = 0.2
        @ben_profile.save!
        @profiles = Profile.search_profiles("", "")
        assert_equal @profiles.first, @user_profile
      end
    end
  end
end
