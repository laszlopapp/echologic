class CreateSpokenLanguages < ActiveRecord::Migration
  def self.up
    create_table :spoken_languages do |t|
      t.integer :user_id, :language_id, :level_id
    end
  end

  def self.down
    drop_table :spoken_languages
  end
end
