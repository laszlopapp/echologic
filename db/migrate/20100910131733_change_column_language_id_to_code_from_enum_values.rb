class ChangeColumnLanguageIdToCodeFromEnumValues < ActiveRecord::Migration
  def self.up
    enum_values = EnumValue.all
    rename_column :enum_values, :language_id, :code
    change_column :enum_values, :code, :string
    EnumValue.all.each_with_index do |enum_value, i|
      enum_value.code = EnumKey.find_by_type_and_key("Language",enum_values[0].language_id).code
      enum_value.save
    end
  end

  def self.down
    change_column :enum_values, :code, :integer
    rename_column :enum_values, :code, :language_id
  end
end
