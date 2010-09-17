class ChangeColumnLanguageIdToCodeFromEnumValues < ActiveRecord::Migration
  def self.up
    rename_column :enum_values, :language_id, :code
    change_column :enum_values, :code, :string
    
    EnumValue.find(:all).each_with_index do |enum_value, i|
      puts Language.find_by_key(enum_value.code.to_i).inspect
      enum_value.code = Language.find_by_key(enum_value.code.to_i).code
      puts enum_value.inspect
      puts enum_value.valid?
      enum_value.save(false)
    end
  end

  def self.down
    change_column :enum_values, :code, :integer
    rename_column :enum_values, :code, :language_id
  end
end
