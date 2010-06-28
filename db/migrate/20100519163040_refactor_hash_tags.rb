class RefactorHashTags < ActiveRecord::Migration
  def self.up
    # Seeding new data into the DB
    Rake::Task['db:seed'].invoke

    %w(echonomyjam echo echocracy echosocial realprices igf klimaherbsttv).each do |name|
      tag = Tag.find_by_value(name)
      if tag
        tag.value= "##{tag.value}" 
        tag.save
      end
    end
  end

  def self.down
    %w(echonomyjam echo echocracy echosocial realprices igf klimaherbsttv).each do |name|
      tag = Tag.find_by_value("##{value}")
      if tag
        tag.value = value
        tag.save!
      end
    end
  end
end
