require 'test_helper'

class EnumValueTest < ActiveSupport::TestCase

  context "an enum value" do
    setup { @enum_value = EnumValue.new }
    subject { @enum_value }
    should_have_many :multilingual_resources
    should_validate_presence_of :key, :subject, :code, :description
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
