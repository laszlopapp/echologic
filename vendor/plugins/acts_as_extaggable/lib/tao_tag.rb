class TaoTag < ActiveRecord::Base
  include ActsAsTaggable::ActiveRecord::Backports if ::ActiveRecord::VERSION::MAJOR < 3
  attr_accessible :tag, :tag_id, :context_id,
                  :tao, :tao_type, :tao_id

  ############################
  #     Associations         #
  ############################
  belongs_to :tag
  belongs_to :tao, :polymorphic => true

  belongs_to :context, :class_name => "EnumKey", :foreign_key => 'context_id'

  ############################
  #     Validations          #
  ############################
  validates_presence_of :context_id
  validates_presence_of :tag_id
  validates_uniqueness_of :tag_id, :scope => [:tao_type, :tao_id, :context_id]

  named_scope :in_context, lambda {|context| {:conditions => ["context_id = ?", context]}}
  named_scope :tag_id_and_tao_id_and_type_and_context_id,
              lambda { |tag_id, tao_id, tao_type, context_id| {
                :conditions => ["tag_id = ? AND (tao_id = ? OR tao_id is null) AND tao_type = ? AND context_id = ?",
                                tag_id, tao_id, tao_type, context_id] }
              }

    class << self
    def create_for(tags,language_id,attributes)
      tags.map { |tag|
        tag_obj = Tag.find_or_create_with_value(tag.strip, language_id)
        tao_tag = tag_id_and_tao_id_and_type_and_context_id(
                    tag_obj.id, attributes[:tao_id], attributes[:tao_type],
                    attributes[:context_id]).first ||
                  TaoTag.new(attributes.merge({:tag => tag_obj}))
        tao_tag
      }.compact
    end    
  end
end
