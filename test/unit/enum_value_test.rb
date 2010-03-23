require 'test_helper'

class EnumValueTest < ActiveSupport::TestCase

  context "an enum value" do
    setup { @enum_value = EnumValue.new }
    subject { @enum_value }
    should_belong_to :enum_key
    should_have_db_columns :context
    
    # testing validations (should_validate_presence_of didn't work)
    %w(enum_key_id value language_id).each do |attr|
      context "with no #{attr} set" do 
        setup { @enum_value.send("#{attr}=", nil)
          assert ! @enum_value.valid?
        }
        should("include #{attr} in it's errors") { 
          assert @enum_value.errors[attr]
        }
      end
    end
    
    # EnumValue.languages
        
    should "have a language enum associated" do
      assert ! EnumValue.languages.empty?
      @enum_value.language_id = EnumValue.languages.first.key
      assert_equal @enum_value.language, EnumValue.languages.first
      # @enum_value.language.value
    end
    
  end
end
