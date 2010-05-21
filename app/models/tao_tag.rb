class TaoTag < ActiveRecord::Base
  attr_accessible :tag, :tag_id, :context_id,
                  :tao, :tao_type, :tao_id
                  # :tagger, :tagger_type, :tagger_id

  include ProfileUpdater

  enum :contexts, :enum_name => :tag_contexts

  belongs_to :tag
  belongs_to :tao, :polymorphic => true
  def user
    tao_type == 'User' ? tao : nil
  end
  alias_method :statement_node, :tao
  # belongs_to :tagger, :polymorphic => true
  
  validates_presence_of :context_id
  validates_presence_of :tag_id
  
  validates_uniqueness_of :tag_id, :scope => [:tao_type, :tao_id, :context_id]
 
  validate :user_on_tags_permission, :if => Proc.new {|tao_tag| !tao_tag.statement_node.nil? and tao_tag.tag.value.include?('#')}
 
  named_scope :tag_id_and_tao_id_and_type_and_context_id, lambda { |tag_id, tao_id, tao_type, context_id| { :conditions => ["tag_id = ? AND tao_id = ? AND tao_type = ? AND context_id = ?", tag_id, tao_id, tao_type, context_id] } }
  
  named_scope :tag_id_and_tao_and_type_and_context_id, lambda { |tag_id, tao, tao_type, context_id| { :conditions => ["tag_id = ? AND (tao_id = ? OR tao_id is null) AND tao_type = ? AND context_id = ?", tag_id, tao.id, tao_type, context_id] } }
  
  def user_on_tags_permission
    errors.add(:tag, "\"#{tag.value}\" is a topic tag and can only be defined by the Editor") if
       !statement_node.creator.has_role?(:editor)
  end
  
  
  class << self
    def create_for(tags,language_id,attributes)
      tags.map { |tag|
        tag_obj = Tag.find_or_create_with_named_by_value(tag.strip, language_id)
        attributes.merge!(:tag_id => tag_obj.id)
        if attributes[:tao_type].eql? "StatementNode"
          tao_tag = tag_id_and_tao_and_type_and_context_id(attributes[:tag_id], attributes[:tao], attributes[:tao_type], attributes[:context_id]).first || TaoTag.create(attributes)
          tao_tag
        else
          tao_tag = tag_id_and_tao_id_and_type_and_context_id(attributes[:tag_id], attributes[:tao_id], attributes[:tao_type], attributes[:context_id]).first || TaoTag.create(attributes)
          tao_tag.new_record? ? nil : tao_tag
        end
      }.compact
    end
    

    
    def valid_contexts(class_name)
      EnumKey.by_key.find_all_by_id(ValidContext.find_all_by_tao_type(class_name).map{|vc|vc.context_id})
    end    
  end
end
