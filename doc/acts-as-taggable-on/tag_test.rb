require 'test_helper'

class TagTest < ActiveSupport::TestCase

  context "a Tag" do
    setup do
      @tag = Tag.new
      @user = TaggableModel.create(:name => "Pablo")
    end
    
    subject {@tag}
    
    context "named like any" do
      setup do
        Tag.create(:name => "awesome")
        Tag.create(:name => "epic")
      end
      
      should("find both tags") do
        Tag.named_like_any(["awesome", "epic"]).should have(2).items
      end
    end
    
    context "find or create by name" do
      setup do
        @tag.name = "awesome"
        @tag.save
      end
      
      should("find by name") do
        Tag.find_or_create_with_like_by_name("awesome").should == @tag
      end
      
      should("find by name case insensitive") do
        Tag.find_or_create_with_like_by_name("AWESOME").should == @tag
      end
      
      should "xcreate by name" do
        lambda {
          Tag.find_or_create_with_like_by_name("epic")
        }.should change(Tag, :count).by(1)
      end
    end
    
    context "find or create all by any name" do
      setup do
        @tag.name = "awesome"
        @tag.save
      end
      
      should("find by name") do
        Tag.find_or_create_all_with_like_by_name("awesome").should == [@tag]
      end
      
      should("find by name case insensitive") do
        Tag.find_or_create_all_with_like_by_name("AWESOME").should == [@tag]
      end
      
      should("create by name") do
        lambda {
          Tag.find_or_create_all_with_like_by_name("epic")
        }.should change(Tag, :count).by(1)
      end
      
      should("find or create by name") do
        lambda {
          Tag.find_or_create_all_with_like_by_name("awesome", "epic").map(&:name).should == ["awesome", "epic"]
        }.should change(Tag, :count).by(1)      
      end
      
      should("return an empty array if no tags are specified") do
        Tag.find_or_create_all_with_like_by_name([]).should == []
      end
    end

    should("require a name") do
      @tag.valid?
      @tag.errors.on(:name).should == "can't be blank"
      @tag.name = "something"
      @tag.valid?
      @tag.errors.on(:name).should be_nil
    end
    
    should("equal a tag with the same name") do
      @tag.name = "awesome"
      new_tag = Tag.new(:name => "awesome")
      new_tag.should == @tag
    end
    
    should("return its name when to_s is called") do
      @tag.name = "cool"
      @tag.to_s.should == "cool"
    end
    
    should("have named_scope named(something)") do
      @tag.name = "cool"
      @tag.save!
      Tag.named('cool').should include(@tag)
    end
    
    should("have named_scope named_like(something)") do
      @tag.name = "cool"
      @tag.save!
      @another_tag = Tag.create!(:name => "coolip")
      Tag.named_like('cool').should include(@tag, @another_tag)
    end
  end
  
end
