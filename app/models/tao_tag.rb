class TaoTag < ActiveRecord::Base
  attr_accessible :tag, :tag_id, :context_id,
                  :tao, :tao_type, :tao_id
                  # :tagger, :tagger_type, :tagger_id

  include ProfileUpdater

  enum :contexts, :enum_name => :tag_contexts

  belongs_to :tag
  belongs_to :tao, :polymorphic => true
  belongs_to :user, :foreign_key => :tao_id, :validate => Proc.new {|x| x.tao_type == 'User'}
  # belongs_to :tagger, :polymorphic => true
  
  validates_presence_of :context_id
  validates_presence_of :tag_id
  
  validates_uniqueness_of :tag_id, :scope => [:tao_type, :tao_id, :context_id]
  
  class << self
    def create_for(tags,language_id,attributes)
      tags.map { |tag|
        tag_obj = Tag.find_or_create_with_named_by_value(tag.strip, language_id)
        tao_tag = create(attributes.merge(:tag_id => tag_obj.id))
        tao_tag.new_record? ? nil : tao_tag
      }.compact
    end
    
    def valid_contexts(class_name)
      EnumKey.by_key.find_all_by_id(ValidContext.find_all_by_tao_type(class_name).map{|vc|vc.context_id})
    end    
  end
end
