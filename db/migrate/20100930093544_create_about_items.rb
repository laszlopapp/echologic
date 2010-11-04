class CreateAboutItems < ActiveRecord::Migration
  def self.up
    create_table :about_items do |t|
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.string :name
      t.string :responsibility
      t.text :description
      t.integer :about_category_id
      t.integer :index
      t.timestamps
    end

    # Translation table for descriptions
    create_table :about_item_translations do |t|
      t.integer :about_item_id
      t.string :locale
      t.string :responsibility
      t.text :description
    end

    # Add new enums for AboutCategory
    Rake::Task['db:seed'].invoke
  end


  def self.down
    drop_table :about_items
    drop_table :about_item_translations
    EnumValue.enumeration_model_updates_permitted = true
    AboutCategory.all.each do |c|
      EnumValue.destroy_all({:enum_key_id => c.id})
    end
    EnumValue.purge_enumerations_cache
    EnumValue.enumeration_model_updates_permitted = false
    AboutCategory.enumeration_model_updates_permitted = true
    AboutCategory.destroy_all
    AboutCategory.purge_enumerations_cache
    AboutCategory.enumeration_model_updates_permitted = false
  end
end
