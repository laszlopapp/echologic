class FeaturedTopicTagsWithoutLanguage < ActiveRecord::Migration
  def self.up

    # Updating featured topic tags to be language indifferent
    %w(echonomyjam echo echocracy echosocial realprices igf klimaherbsttv).each do |name|
      tags = Tag.all(conditions => {:value => "#{name}"}, :order => "created_at DESC")
      next if tags.blank?
      oldest_tag = tags.pop
      tags.each do |tag|
        tag.destroy
      end
      oldest_tag.language = nil
      oldest_tag.save!
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
