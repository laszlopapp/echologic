class ChangeColumnEnumNameToTypeInEnumKey < ActiveRecord::Migration
  def self.up
    EnumKey.all.each do |enum_key|
      enum_key.enum_name = enum_key.enum_name.singularize.classify 
      enum_key.save
    end
    rename_column :enum_keys, :enum_name, :type
  end

  def self.down
    rename_column :enum_keys, :type, :enum_name
    EnumKey.all.each do |enum_key|
      enum_key.enum_name = enum_key.enum_name.underscore.pluralize
      enum_key.save
    end
  end
end
