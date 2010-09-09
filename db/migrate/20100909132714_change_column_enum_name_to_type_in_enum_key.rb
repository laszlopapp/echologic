class ChangeColumnEnumNameToTypeInEnumKey < ActiveRecord::Migration
  def self.up
    rename_column :enum_keys, :enum_name, :type
  end

  def self.down
    rename_column :enum_keys, :type, :enum_name
  end
end
