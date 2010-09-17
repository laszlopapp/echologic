class ChangeColumnLanguageIdToCodeFromEnumValues < ActiveRecord::Migration
  def self.up
    change_column :enum_values, :language_id, :string
    rename_column :enum_values, :language_id, :code
    
    Rake::Task['db:seed'].invoke
#    EnumValue.find(:all).each_with_index do |enum_value, i|
#      enum_value.code = Language.find_by_key(enum_value.code.to_i).code
#      enum_value.save(false)
#    end
  end

  def self.down
    change_column :enum_values, :code, :integer
    rename_column :enum_values, :code, :language_id
  end
end
