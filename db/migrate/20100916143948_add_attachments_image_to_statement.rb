class AddAttachmentsImageToStatement < ActiveRecord::Migration
  def self.up
    add_column :statements, :statement_image_id, :integer
    
    create_table :statement_images do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
    end
    Statement.all.each{|s|s.update_attribute(:statement_image, StatementImage.new)}
  end

  def self.down
    remove_column :statements, :statement_image_id
    drop_table :statement_images
  end
end
