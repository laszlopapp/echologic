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
      @statement_document.language_id = StatementDocument.languages.first.key
      assert_equal @statement_document.language, StatementDocument.languages.first
      # @enum_value.language.value
    end

    context "with translations" do
      setup do  
        @statement_document.update_attributes(:title => 'A document', :text => 'the documents body', :language_id => 1, :statement_id => 1)
        @statement_document.author = User.first
        @translated_statement_document = StatementDocument.create(:title => 'A document', :text => 'the documents body', :language_id => 1, :statement_id => 1)
        @translated_statement_document.author = User.first
        @translated_statement_document.translated_document_id = @statement_document.id
        @translated_statement_document.save!
      end
    
      should "be able to be a translation of another statement" do
        @translated_statement_document.original.should_be @statement_document
      end

      should "be able to have translations" do
        @statement_document.translations.should_be [@translated_statement_document]
      end

      should "tell if it is the original document" do
        assert @statement_document.original?
        assert ! @translated_statement_document.original?
      end
    end
  end
end
