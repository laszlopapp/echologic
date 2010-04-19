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
        @spoken_language=SpokenLanguage.create!(:user => User.find_by_email('user@echologic.org'), :language => EnumKey.find_by_code("pt"), :level => EnumKey.find_by_code("intermediate"))
      end
      
      should "be able to access its language data" do
        assert_equal @spoken_language.language.name, "languages"
        assert_equal @spoken_language.level.name, "language_levels"
      end
    end
    
    context("having already an instance of one language to an user") do
      setup do 
        @spoken_language = SpokenLanguage.find_by_user_id(User.find_by_email('user@echologic.org').id)
      end
      
      should "should fail to associate the same spoken language to the same user" do
        @spoken_language_2 = SpokenLanguage.new  
        @spoken_language_2.user = @spoken_language.user
        @spoken_language_2.language_id = @spoken_language.language
        @spoken_language_2.level_id = @spoken_language.level  
        assert !@spoken_language_2.save
      end
    end  
    
  end
end
