class CreateEnumKeys < ActiveRecord::Migration
  def self.up
    create_table :enum_keys do |t|
      t.string :code, :enum_name, :description
      t.integer :key
    end
  end

  def self.down
    drop_table :enum_keys
  end
end
