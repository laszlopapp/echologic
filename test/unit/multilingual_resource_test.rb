require 'test_helper'

class MultilingualResourceTest < ActiveSupport::TestCase

  context "a multilingual resource" do
    setup { @multilingual_resource = MultilingualResource.new }
    subject { @multilingual_resource }
    should_belong_to :enum_value
    #should_validate_presence_of :enum_value_id, :value, :language_id, :context
    %w(enum_value_id value language_id context).each do |attr|
      context "with no #{attr} set" do 
        setup { @multilingual_resource.send("#{attr}=", nil)
          assert ! @multilingual_resource.valid?
        }
        should("include #{attr} in it's errors") { 
          assert @multilingual_resource.errors[attr]
        }
      end
    end
  end
end
