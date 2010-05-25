require 'test_helper'

class StatementDocumentTest < ActiveSupport::TestCase
  
  context "a statement document" do
    setup { @statement_document = StatementDocument.new }
    subject { @statement_document }
    
    should_belong_to :statement
    
    # check for validations (should_validate_presence_of didn't work)
    %w(language_id statement_id author_id title text).each do |attr|
      context "with no #{attr} set" do 
        setup { @statement_document.send("#{attr}=", nil)
          assert ! @statement_document.valid?
        }
        should("include #{attr} in it's errors") { 
          assert @statement_document.errors[attr]
        }
      end
    end

    
    # EnumValue.languages
  
    should "have a language enum associated" do
      assert ! StatementDocument.languages.empty?
    end

    context "with translations" do
      setup do  
        @statement_document.update_attributes(:title => 'A document', :text => 'the documents body', :statement_id => 1)
        @statement_document.language = StatementDocument.languages.first
        @statement_document.author = User.first
        @statement_document.save!
        @translated_statement_document = StatementDocument.create(:title => 'Ein dokument', :text => 'the documents body', :language_id => StatementDocument.languages.last.key, :statement_id => 1)
        @translated_statement_document.author = User.first
        @translated_statement_document.translated_document_id = @statement_document.id
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
        assert_equal @statement_document.language, StatementDocument.languages.first
      end

    end
  end
end
