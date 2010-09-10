class EnumValue < ActiveRecord::Base
  acts_as_enumerated :order => "'key ASC'"
  belongs_to :enum_key
  validates_presence_of :enum_key_id, :value, :key
  validates_uniqueness_of :key, :scope => :enum_key_id
  
#  named_scope :for_key, lambda { |key| { :conditions => ['key = ?', key ], :limit => 1 } }
  
  
  class << self
  
    def lookup_code(arg)
      all_by_code[arg][Language[I18n.locale].key]
    end
  
    def all_by_code
      return @all_by_code if @all_by_code
      begin
        @all_by_code = all.inject({}) { |memo, item| 
          memo[item.enum_key.code] = memo[item.enum_key.code].nil? ? Hash[item.key => item] : memo[item.enum_key.code].merge({item.key => item})
          memo}.freeze
      rescue NoMethodError => err
        if err.name == :code
          raise TypeError, "#{self.name}: you need to define a 'code' column in the table '#{table_name}'"
        end
        raise
      end            
    end
  end 
end
