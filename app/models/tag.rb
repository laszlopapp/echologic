class Tag < ActiveRecord::Base
  attr_accessible :value, :language_id

  enum :language, :enum_name => :languages

  # ASSOCIATIONS
  has_many :tao_tags, :dependent => :destroy

  # VALIDATIONS
  validates_presence_of :value
  validates_uniqueness_of :value

  # NAMED SCOPES
  def self.uber (*value)
    value.each {|d| puts d.class }
  end

  named_scope :with_value, lambda { |value|
    { :conditions => ["value = ?", value] }
  }
  named_scope :with_values, lambda { |*values|
    { :conditions => values.map { |value|
        sanitize_sql(["value = ?", value.to_s])
      }.join(" OR ")
    }
  }
  named_scope :with_value_like, lambda { |value|
    { :conditions => ["value LIKE ?", "%#{value}%"] }
  }
  named_scope :with_values_like, lambda { |*values|
    { :conditions => values.map { |value|
        sanitize_sql(["value LIKE ?", "%#{value.to_s}%"])
      }.join(" OR ")
    }
  }

  # CLASS METHODS
  def self.find_or_create_with_value(value, language_id = nil)
    with_value(value).first || Tag.create(:value => value, :language_id => language_id)
  end

  def self.find_or_create_with_value_like(value, language_id = nil)
    with_value_like(value).first || Tag.create(:value => value, :language_id => language_id)
  end

  # Creates one tag for each value if it is not found using LIKE.
  # The last item in the list can be a language_id to use for new tags.
  def self.find_or_create_all_with_values_like(*values)
    values = [values].flatten
    return [] if values.empty?

    language_id = values.last.kind_of?(Numeric) ? values.pop : nil

    existing_tags = Tag.with_values(values).all
    new_tag_values = values.reject { |value|
      existing_tags.any? { |tag| tag.value.mb_chars.downcase == value.mb_chars.downcase }
    }
    created_tags  = new_tag_values.map { |value|
      Tag.create(:value => value, :language_id => language_id)
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

end
