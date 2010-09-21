class EnumValue < ActiveRecord::Base
  acts_as_enumerated :order => "'code ASC'"
  belongs_to :enum_key
  validates_presence_of :enum_key_id, :code, :value
  validates_uniqueness_of :code, :scope => :enum_key_id

  # Redefinitions of some enumerated methods
  class << self

    def lookup_code(arg1,arg2=Language[I18n.locale].code)
      all_by_code[arg1][arg2]
    end

    def all_by_code
      return @all_by_code if @all_by_code
      begin
        @all_by_code = all.inject({}) { |memo, item|
          memo[item.enum_key.code] =
            memo[item.enum_key.code].nil? ? Hash[item.code => item] : memo[item.enum_key.code].merge({item.code => item})
          memo
        }.freeze
      rescue NoMethodError => err
        if err.name == :code
          raise TypeError, "#{self.name}: you need to define a 'code' column in the table '#{table_name}'"
        end
        raise
      end
    end

  end
end
