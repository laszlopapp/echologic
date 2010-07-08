class Tag < ActiveRecord::Base
  include ActsAsTaggable::ActiveRecord::Backports if ::ActiveRecord::VERSION::MAJOR < 3
  attr_accessible :value, :language_id
  acts_as_authorization_object

  enum :language, :enum_name => :languages

  # ASSOCIATIONS
  has_many :tao_tags, :dependent => :destroy

  # VALIDATIONS
  validates_presence_of :value
  validates_uniqueness_of :value

  # NAMED SCOPES
  def self.using_postgresql?
    connection.adapter_name == 'PostgreSQL'
  end
    
  def self.uber (*value)
    value.each {|d| puts d.class }
  end

  named_scope :named, lambda { |value|
    { :conditions => ["value = ?", value] }
  }
  named_scope :named_any, lambda { |*list|
    { :conditions => list.map { |tag| sanitize_sql(["value = ?", tag.to_s]) }.join(" OR ")
    }
  }
  named_scope :named_like, lambda { |value|
    { :conditions => ["value LIKE ?", "%#{value}%"] }
  }
  named_scope :named_like_any, lambda { |*list|
    { :conditions => list.map { |tag| sanitize_sql(["value LIKE ?", "%#{tag.to_s}%"]) }.join(" OR ")
    }
  }

  # CLASS METHODS
  def self.find_or_create_with_named_by_value(value)
    named(value).first || Tag.create(:value => value)
  end

  def self.find_or_create_with_like_by_value(value)
    named_like(value).first || Tag.create(:value => value)
  end

  def self.find_or_create_all_with_like_by_value(*list)
    list = [list].flatten

    return [] if list.empty?

    existing_tags = Tag.named_any(list).all
    new_tag_values = list.reject { |value|
      existing_tags.any? { |tag| tag.value.mb_chars.downcase == value.mb_chars.downcase }
    }
    created_tags  = new_tag_values.map { |value|
      Tag.create(:value => value)
    }

    existing_tags + created_tags
  end

  # INSTANCE METHODS
  def ==(object)
    super || (object.is_a?(Tag) && value == object.value)
  end

  def to_s
    value
  end

  def count
    read_attribute(:count).to_i
  end

  class << self
    private 
      def like_operator
        using_postgresql? ? 'ILIKE' : 'LIKE'
      end
      
      def comparable_name(str)
        RUBY_VERSION >= "1.9" ? str.downcase : str.mb_chars.downcase
      end
  end

end
