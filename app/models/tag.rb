class Tag < ActiveRecord::Base
    attr_accessible :value, :language_id
  
  enum :languages
  
  ### ASSOCIATIONS:
  
  has_many :tao_tags, :dependent => :destroy
  
  ### VALIDATIONS:
  
  validates_presence_of :value
  validates_uniqueness_of :value
  
  ### NAMED SCOPES:
  
  def self.uber (*value)
    value.each {|d| puts d.class }
  end
    
  named_scope :named, lambda { |language_id, value| { :conditions => ["value LIKE ? AND language_id = ?", value, language_id] } }
  named_scope :named_any, lambda { |language_id, *list| { :conditions => list.map { |tag| sanitize_sql(["value LIKE ?", tag.to_s]) }.join(" OR ").concat(sanitize_sql([" AND language_id = ?", language_id])) } }  
  named_scope :named_like, lambda { |language_id, value| { :conditions => ["value LIKE ? AND language_id = ?", "%#{value}%", language_id] } }
  named_scope :named_like_any, lambda { |language_id, *list| { :conditions => list.map { |tag| sanitize_sql(["value LIKE ?", "%#{tag.to_s}%"]) }.join(" OR ").concat(sanitize_sql([" AND language_id = ?", language_id])) } }
  
  ### CLASS METHODS:
  
  def self.find_or_create_with_named_by_value(value, language_id = self.languages.first.id)
    named(language_id, value).first || Tag.create(:value => value, :language_id => language_id)
  end
  
  def self.find_or_create_with_like_by_value(value, language_id = self.languages.first.id)
    named_like(language_id, value).first || Tag.create(:value => value, :language_id => language_id)
  end
  
  def self.find_or_create_all_with_like_by_value(*list)
    list = [list].flatten
    
    return [] if list.empty?
  
    language_id = list.last.kind_of?(Numeric) ? list.pop : self.languages.first.id

    existing_tags = Tag.named_any(language_id, list).all
    new_tag_values = list.reject { |value| existing_tags.any? { |tag| tag.value.mb_chars.downcase == value.mb_chars.downcase } }
    created_tags  = new_tag_values.map { |value| Tag.create(:value => value, :language_id => language_id) }
  
    existing_tags + created_tags    
  end
  
  ### INSTANCE METHODS:
  
  def ==(object)
    super || (object.is_a?(Tag) && value == object.value && language_id == object.language_id)
  end
  
  def to_s
    value
  end
  
  def count
    read_attribute(:count).to_i
  end

end
