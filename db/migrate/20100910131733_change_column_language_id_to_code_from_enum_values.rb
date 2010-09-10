class ChangeColumnLanguageIdToCodeFromEnumValues < ActiveRecord::Migration
  def self.up
    rename_column :enum_values, :language_id, :code
    change_column :enum_values, :code, :string
  end

  def self.down
    change_column :enum_values, :code, :integer
    rename_column :enum_values, :code, :language_id
  end
end
