class Tag < ActiveRecord::Base
  # has_many :concernments
  # has_many :users, :through => :concernments
  # has_many :statements, :foreign_key => 'category_id'

  attr_accessible :value
  
  ### ASSOCIATIONS:
  
  has_many :tao_tags, :dependent => :destroy
  
  ### VALIDATIONS:
  
  validates_presence_of :value
  validates_uniqueness_of :value
  
  ### NAMED SCOPES:
  
  named_scope :named, lambda { |value| { :conditions => ["value LIKE ?", value] } }
  named_scope :named_any, lambda { |list| { :conditions => list.map { |tag| sanitize_sql(["value LIKE ?", tag.to_s]) }.join(" OR ") } }
  named_scope :named_like, lambda { |value| { :conditions => ["value LIKE ?", "%#{value}%"] } }
  named_scope :named_like_any, lambda { |list| { :conditions => list.map { |tag| sanitize_sql(["value LIKE ?", "%#{tag.to_s}%"]) }.join(" OR ") } }
  
  ### CLASS METHODS:
  
  def self.find_or_create_with_like_by_value(value)
    named_like(value).first || create(:value => value)
  end
  
  def self.find_or_create_all_with_like_by_value(*list)
    list = [list].flatten
    
    return [] if list.empty?

    existing_tags = Tag.named_any(list).all
    new_tag_values = list.reject { |value| existing_tags.any? { |tag| tag.value.mb_chars.downcase == value.mb_chars.downcase } }
    created_tags  = new_tag_values.map { |value| Tag.create(:value => value) }
  
    existing_tags + created_tags    
  end
  
  ### INSTANCE METHODS:
  
  def ==(object)
    super || (object.is_a?(Tag) && value == object.value)
  end
  
  def to_s
    value
  end
  
  def count
    read_attribute(:count).to_i
  end

end
