class CreateAboutItems < ActiveRecord::Migration
  def self.up
    create_table :about_items do |t|
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.string :name
      t.text :description
      t.integer :collaboration_team_id
      t.integer :index
      t.timestamps
    end
    
    # Descriptions' translations table
    create_table :about_item_translations do |t|
      t.integer :about_item_id
      t.string :locale
      t.text :description
    end
  end

  def self.down
    drop_table :about_items
    drop_table :about_item_translations
  end
end
