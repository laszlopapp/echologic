require 'test_helper'

class EnumValueTest < ActiveSupport::TestCase

  context "an enum value" do
    setup { @enum_value = EnumValue.new }
    subject { @enum_value }
    should belong_to :enum_key
    should have_db_column :context
    
    # testing validations (should_validate_presence_of didn't work)
    %w(enum_key_id value code).each do |attr|
      context "with no #{attr} set" do 
        setup { 
          @enum_value.send("#{attr}=", nil)
          assert ! @enum_value.valid?
        }
        should("include #{attr} in it's errors") { 
          assert @enum_value.errors[attr]
        }
      end
    end
    
    # EnumValue.languages
   
    context "being saved" do
      setup {@save = @enum_value.update_attributes({:enum_key_id => Language.first.id, :value => 'Test', :code => Language.first.code})}
      should "throw an error due to an already existing instance of this enum key translation in the aforementioned language" do
        assert !@save        
      end
    end
    
  end
end
