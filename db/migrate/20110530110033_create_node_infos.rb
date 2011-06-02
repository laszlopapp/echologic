class CreateNodeInfos < ActiveRecord::Migration
  def self.up
    add_column :statements, :info_type_id, :integer
    create_table :statement_datas do |t|
      t.string :type
      t.string :info_file_name
      t.string :info_content_type
      t.integer :info_file_size
      t.datetime :info_updated_at
      t.string :info_url
      t.integer :statement_id
    end
  end

  def self.down
    remove_column :statements, :info_type_id
    drop_table :statement_datas
  end
end
