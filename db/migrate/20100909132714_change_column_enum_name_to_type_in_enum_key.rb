class ChangeColumnEnumNameToTypeInEnumKey < ActiveRecord::Migration
  def self.up
    rename_column :enum_keys, :enum_name, :type
    
    EnumKey.all.each do |enum_key|
      enum_key.type = enum_key.type.singularize.classify 
      enum_key.save
    end
  end

  def self.down
    rename_column :enum_keys, :type, :enum_name
    EnumKey.all.each do |enum_key|
      enum_key.enum_name = enum_key.enum_name.underscore.pluralize
      enum_key.save
    end
  end
end
