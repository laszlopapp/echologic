class AddNameToAboutItemTranslation < ActiveRecord::Migration
  def self.up
    add_column :about_item_translations, :name, :string
  end

  def self.down
    remove_column :about_item_translations, :name 
  end
end
