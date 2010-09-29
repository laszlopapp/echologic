class ChangeColumnLanguageIdToCodeFromEnumValues < ActiveRecord::Migration
  def self.up
    add_column :enum_values, :code, :string
    Language.all.each do |language|
      execute "UPDATE enum_values SET code = '#{language.code}' WHERE language_id = #{language.id}"
    end
    remove_column :enum_values, :language_id
    add_index :enum_values, [:enum_key_id, :code, :id], :name => "idx_enum_values_enum_key_code_pk"
  end

  def self.down
    add_column :enum_values, :language_id, :integer
    Language.all.each do |language|
      execute "UPDATE enum_values SET language_id = #{language.id} WHERE code = '#{language.code}'"
    end
    remove_column :enum_values, :code
  end
end
