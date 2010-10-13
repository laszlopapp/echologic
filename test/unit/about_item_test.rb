require 'test_helper'

class AboutItemTest < ActiveSupport::TestCase
  context "an about item" do

    setup { @about_item = AboutItem.new }
    subject { @about_item }

    # validates no invalid indexes
    [nil, -1].each do |value|
      context("with index set to #{value}") do
        setup {
          @about_item.send("index=", value)
          assert ! @about_item.valid?
        }
        should("include index in it's errors") {
          assert @about_item.errors["index"]
        }
      end
    end

    context "being saved" do
      setup do
        @about_item = AboutItem.new(:name => 'Jimi Hendrix', :description => 'Xcuse me while i kiss this guy!', :index => '1') 
        @about_item.collaboration_team = CollaborationTeam[:core_team]
        @about_item.save!
        I18n.locale = 'de'
        @about_item.description = 'Verzeiht mir während ich diesen Kerl küsse!'
        @about_item.save!
      end

      should "be able to access its about item data" do
        I18n.locale = 'de'
        assert_equal @about_item.name, "Jimi Hendrix"
        assert_equal @about_item.description, "Verzeiht mir während ich diesen Kerl küsse!"
        assert_equal @about_item.collaboration_team.value, "Ständiges Team"
        I18n.locale = 'en'
        assert_equal @about_item.description, "Xcuse me while i kiss this guy!"
        assert_equal @about_item.index, 1
      end      
    end
  end
end
