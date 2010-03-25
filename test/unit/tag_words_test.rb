class TagWordTest < ActiveSupport::TestCase
  context "a tag word" do
    setup { @tag_word = TagWord.new }
    subject ( @tag_word )
    
    should_belong_to :tag
    should_validate_presence_of :tag_id, :language_id, :value
  end
end
