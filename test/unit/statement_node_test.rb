require 'test_helper'

class StatementNodeTest < ActiveSupport::TestCase

  context "a statement node" do

    setup { @statement_node = Question.new }
    subject { @statement_node }

    should_belong_to :statement, :creator, :state
    should_have_many :tao_tags
    should_have_many :statement_documents
    should_have_many :tags

    # should_validate_associated :creator, :document, :category

    # validates no invalid states
    [nil, "invalid state"].each do |value|
      context("with state set to #{value}") do
        setup {
          @statement_node.send("state_id=", value)
          assert ! @statement_node.valid?
        }
        should("include state in it's errors") {
          assert @statement_node.errors["state_id"]
        }
      end
    end

    # check for validations (should_validate_presence_of didn't work)
    %w(creator_id state_id).each do |attr|
      context "with no #{attr} set" do
        setup { @statement_node.send("#{attr}=", nil)
          assert ! @statement_node.valid?
        }
        should("include #{attr} in it's errors") {
          assert @statement_node.errors[attr]
        }
      end
    end

    context("should be in a tree") do
      should_belong_to :root_statement
      should_have_db_columns :root_id, :parent_id
    end

    context("should be echoable") do
      should_have_db_columns :echo_id
      should_belong_to :echo
      should_have_many :user_echos
    end

    [Question, Proposal, ImprovementProposal].each do |subtype|
      context("with type #{subtype.to_s}") do
        setup do
          @statement_node = subtype.new
        end
        should "tell us what type it is of" do
          assert_true @statement_node.send(subtype.name.underscore+'?')
        end
      end
    end

    context "being saved" do
      setup do
        @statement_node.add_statement_document!(:title => 'A new Document',
                                                :text => 'with a very short body, dude!',
                                                :language_id => EnumKey.find_by_code("en").id,
                                                :author_id => User.first.id,
                                                :original_language_id => EnumKey.find_by_code("en").id)
        @statement_node.tao_tags << TaoTag.new(:tag_id => Tag.first.id,
                                               :tao_type => StatementNode.name,
                                               :context_id => EnumKey.find_by_code("topic").id)
        @statement_node.creator_id = User.first.id
        @statement_node.state_id = StatementNode.statement_states('published').id
        @statement_node.save!
      end

      should "be able to access its statement documents data" do
        assert_equal @statement_node.translated_document(
          [EnumKey.find_by_code("en").id]).title, "A new Document"
        assert_equal @statement_node.translated_document(
          [EnumKey.find_by_code("en").id]).text, "with a very short body, dude!"
      end
    end

  end # main context

end # test
