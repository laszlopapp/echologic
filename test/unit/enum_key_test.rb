require 'test_helper'

class EnumKeyTest < ActiveSupport::TestCase

  context "an enum key" do
    setup { @enum_key = EnumKey.new }
    subject { @enum_key }
    should_have_many :enum_values
        
    # check for validations (should_validate_presence_of didn't work)
    %w(key type code).each do |attr|
      context "with no #{attr} set" do 
        setup { @enum_key.send("#{attr}=", nil)
          assert ! @enum_key.valid?
        }
        should("include #{attr} in it's errors") { 
          assert @enum_key.errors[attr]
        }
      end
    end
    
#    context "being saved" do
#      setup { @enum_key.update_attributes!(:key => 1, :type => 'need_type', :code => 'financial', :description => 'need of financial support') }
#      should("return value for language_id") do
#        @enum_key.enum_values.create!(:language_id => 1, :value => 'Finanzbedarf')
#        @enum_key.enum_values.create!(:language_id => 2, :value => 'Financial Needs')
#        assert ! @enum_key.enum_values.for_language_id(1).empty?
#        assert_equal @enum_key.enum_values.for_language_id(1).first.value, 'Finanzbedarf'
#      end
#    end  
    
    # subjects: 
    # statements -> original_language_id
    # multilingual_resources -> language_id
    # statment_documents -> language_id
    # web_addresses -> type_id
    
    # not yet implemented:
    # tags -> original_languae_id
    # tao_tags -> context_id
    # tag_words -> language_id
    # tao_contexts -> context_id
    # organizations -> type_id
    # needs -> type_id
    
    # actual subjects:
    # * language
    # * web_address_type
    # not yet implemented
    # * context
    # * organization_type
    # * need_type
  end
end
