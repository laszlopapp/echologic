class ValidContext < ActiveRecord::Base
  attr_accessible :tao_type, :context_id

  enum :context, :enum_name => :tag_contexts

  validates_presence_of :tao_type, :context_id
  
  
  def self.valid_contexts(class_name)
    EnumKey.by_key.all(:conditions => ["id IN (?)",ValidContext.find_all_by_tao_type(class_name).map{|vc|vc.context_id}])
  end
  
end
