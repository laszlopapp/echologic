class AddNewAboutItemStrategicPartners < ActiveRecord::Migration
  def self.up
    Rake::Task['db:seed'].invoke
    add_column :about_items, :url, :string
  end

  def self.down
    remove_column :about_items, :url
  end
end