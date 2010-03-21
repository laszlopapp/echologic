class CreateMultilingualResource < ActiveRecord::Migration
  def self.up
    create_table :multilingual_resource do |t|
      t.integer :enum_value_id, :language_id
      t.string :context, :value
    end
  end

  def self.down
    drop_table :multilingual_resource
  end
end
