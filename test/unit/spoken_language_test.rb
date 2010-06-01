require 'test_helper'

class SpokenLanguageTest < ActiveSupport::TestCase
  context "a spoken language" do

    setup { @spoken_language = SpokenLanguage.new }
    subject { @spoken_language }

    should_belong_to :user


    context("should have a language associated") do
      should_belong_to :language
      should_have_db_columns :language_id
    end
    context("should have a language level associated") do
      should_belong_to :level
      should_have_db_columns :level_id
    end

    context "being saved" do
      setup do
        @spoken_language.update_attributes!(:user => User.first, :language => SpokenLanguage.languages("en"), :level => SpokenLanguage.language_levels("intermediate"))
      end

      should "be able to access its language data" do
        assert_equal @spoken_language.language.enum_name, "languages"
        assert_equal @spoken_language.level.enum_name, "language_levels"
      end
      should "not be able to associate the same spoken language to the same user" do
        @spoken_language_2 = SpokenLanguage.new
        @spoken_language_2.user = @spoken_language.user
        @spoken_language_2.language = @spoken_language.language
        @spoken_language_2.level = @spoken_language.level
        assert_equal @spoken_language_2.save, false
      end
    end
  end
end
