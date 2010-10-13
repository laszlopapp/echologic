require 'test_helper'

class SpokenLanguageTest < ActiveSupport::TestCase
  context "a spoken language" do

    setup { @spoken_language = SpokenLanguage.new }
    subject { @spoken_language }

    should belong_to :user


    context("should have a language associated") do
      should have_db_column :language_id
    end
    context("should have a language level associated") do
      should have_db_column :level_id
    end

    context "being saved" do
      setup do
        @spoken_language.update_attributes!(:user => User.first, :language => Language["en"], :level => LanguageLevel["intermediate"])
      end

      should "be able to access its language data" do
        assert_equal @spoken_language.language.type, "Language"
        assert_equal @spoken_language.level.type, "LanguageLevel"
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
