class ValidContext < ActiveRecord::Base
  attr_accessible :tao_type, :context_id

  enum :context, :enum_name => :tag_contexts

  validates_presence_of :tao_type, :context_id
end
