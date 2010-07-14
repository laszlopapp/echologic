class RefactorHashTags < ActiveRecord::Migration
  def self.up

    # Updating featured topic tags to be #tags
    %w(echonomyjam echo echocracy echosocial realprices igf klimaherbsttv).each do |name|
      tag = Tag.find_by_value(name)
      if tag
        tag.value= "##{tag.value}"
        tag.save
      end
    end

    # Seeding new data into the DB
    Rake::Task['db:seed'].invoke
  end

  def self.down
    %w(echonomyjam echo echocracy echosocial realprices igf klimaherbsttv).each do |name|
      tag = Tag.find_by_value("##{name}")
      tag.value = name
      tag.save!
    end
  end
end
