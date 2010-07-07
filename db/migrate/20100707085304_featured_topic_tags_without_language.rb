class FeaturedTopicTagsWithoutLanguage < ActiveRecord::Migration
  def self.up

    # Updating featured topic tags to be language indifferent
    %w(echonomyjam echo echocracy echosocial realprices igf klimaherbsttv).each do |name|
      tag = Tag.find_by_value(name)
      tag.language = nil
      tag.save!
    end

  end

  def self.down
    %w(echonomyjam echo echocracy echosocial realprices igf klimaherbsttv).each do |name|
      tag = Tag.find_by_value(name)
      tag.language = Tag.languages("de").first
      tag.save!
    end
  end
end
