class UpdateTagsLanguageId < ActiveRecord::Migration
  def self.up
    Tag.all.each do |tag|
      tag.language = Language["de"] if tag.language.nil?
      tag.save
    end
  end

  def self.down
  end
end
