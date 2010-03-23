class CreateEnumValues < ActiveRecord::Migration
  def self.up
    create_table :enum_values do |t|
      t.integer :enum_key_id, :language_id
      t.string :context, :value
    end
  end

  def self.down
    drop_table :enum_values
  end
end
