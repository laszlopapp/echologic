class CreateNodeInfos < ActiveRecord::Migration
  def self.up
    
    create_table :statement_datas do |t|
      t.string :type
      t.string :info_file_name
      t.string :info_content_type
      t.integer :info_file_size
      t.datetime :info_updated_at
      t.string :info_url
      t.integer :info_type_id
      t.integer :statement_id
    end
  end

  def self.down
    drop_table :statement_datas
  end
end
