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
        @spoken_language.update_attributes!(:user => User.first, :language => Enum.find_by_code("english"), :level => Enum.find_by_code("intermediate"))
      end
      
      should "be able to access its language data" do
        assert_equal @spoken_language.language.name, "languages"
        assert_equal @spoken_language.level.name, "language_levels"
      end
    end
    
  end
end
