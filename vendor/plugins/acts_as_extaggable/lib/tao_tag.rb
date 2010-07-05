class TaoTag < ActiveRecord::Base
  attr_accessible :tag, :tag_id, :context_id,
                  :tao, :tao_type, :tao_id

  ############################
  #     Associations         #
  ############################
  belongs_to :tag
  belongs_to :tao, :polymorphic => true

  enum :context, :enum_name => :tag_contexts

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
        tag_obj = Tag.find_or_create_with_named_by_value(tag.strip, language_id)
        tao_tag = tag_id_and_tao_id_and_type_and_context_id(
                    tag_obj.id, attributes[:tao_id], attributes[:tao_type],
                    attributes[:context_id]).first ||
                  TaoTag.new(attributes.merge({:tag => tag_obj}))
        tao_tag
      }.compact
    end

    def valid_contexts(class_name)
      EnumKey.by_key.find_all_by_id(ValidContext.find_all_by_tao_type(class_name).map{|vc|vc.context_id})
    end
  end
end
