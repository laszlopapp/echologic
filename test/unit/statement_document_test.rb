require 'test_helper'

class StatementDocumentTest < ActiveSupport::TestCase
  
  context "a statement document" do
    setup { @statement_document = StatementDocument.new }
    subject { @statement_document }
    
    should_belong_to :statement
    
    # check for validations (should_validate_presence_of didn't work)
    %w(language_id statement title text).each do |attr|
      context "with no #{attr} set" do 
        setup { @statement_document.send("#{attr}=", nil)
          assert ! @statement_document.valid?
        }
        should("include #{attr} in it's errors") {
          assert_not_nil @statement_document.errors[attr]
        }
      end
    end
    %w(author).each do |attr|
      context "with no #{attr} set" do 
        setup { @statement_document.send("#{attr}=", nil)
          assert ! @statement_document.valid?
        }
        should("include #{attr} in it's errors") {
          assert_not_nil @statement_document.statement_history.errors["#{attr}_id"]
        }
      end
    end
    
   
    context "with translations" do
      setup do  
        statement = Statement.new(:original_language => Language["en"])
        @statement_document.update_attributes(:title => 'A document', :text => 'the documents body', :statement => statement)
        @statement_document.language = Language.first
        @statement_document.author = User.first
        @statement_document.action = StatementAction["created"]
        @statement_document.save!
        @translated_statement_document = StatementDocument.new
        @translated_statement_document.update_attributes(:title => 'Ein dokument', :text => 'the documents body', 
                                                                  :language => Language.last, 
                                                                  :statement => statement)
        @translated_statement_document.author = User.first
        @translated_statement_document.action = StatementAction["translated"]
        @translated_statement_document.old_document = @statement_document
        @translated_statement_document.save!
      end
    
      should "be able to be a translation of another statement" do
        assert_equal @translated_statement_document.original, @statement_document
      end

      should "be able to have translations" do
        assert_equal @statement_document.translations, [@translated_statement_document]
      end

      should "tell if it is the original document" do
        assert @statement_document.original?
        assert ! @translated_statement_document.original?
      end
      
      should "have a language associated" do
        assert_equal @statement_document.language, Language.first
      end

    end
  end
end
