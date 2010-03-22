class CreateMultilingualResources < ActiveRecord::Migration
  def self.up
    create_table :multilingual_resources do |t|
      t.integer :enum_value_id, :language_id
      t.string :context, :value
    end
  end

  def self.down
    drop_table :multilingual_resources
  end
end
