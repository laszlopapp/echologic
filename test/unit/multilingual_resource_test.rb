require 'test_helper'

class MultilingualResourceTest < ActiveSupport::TestCase

  context "a multilingual resource" do
    setup { @multilingual_resource = MultilingualResource.new }
    subject { @multilingual_resource }
    should_belong_to :enum_value
    should_validate_presence_of :enum_value_id, :value, :language_id, :context
  end
end
