class CreateEnumValues < ActiveRecord::Migration
  def self.up
    create_table :enum_values do |t|
      t.integer :key
      t.string :subject, :code, :description
    end
  end

  def self.down
    drop_table :enum_values
  end
end
