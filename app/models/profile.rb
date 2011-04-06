require 'rest-open-uri'

class Profile < ActiveRecord::Base

  # Constants
  COMPLETENESS_THRESHOLD = 0.42

  # Every profile has to belong to a user.
  belongs_to :user
  has_many :web_addresses, :through => :user
  has_many :memberships,  :through => :user
  has_many :spoken_languages, :through => :user

  delegate :email, :email=, :affection_tags, :expertise_tags, :engagement_tags, :decision_making_tags, 
           :first_membership, :to => :user


  validates_presence_of :user_id
  validates_length_of :about_me, :maximum => 1024, :allow_nil => true
  validates_length_of :motivation, :maximum => 1024, :allow_nil => true

  # To calculate profile completeness
  include ProfileExtension::Completeness

  # There are two kind of people in the world..
  @@gender = {
    false => I18n.t('users.profile.gender.male'),
    true  => I18n.t('users.profile.gender.female')
  }

  # Access for the class variable
  def self.gender
    @@gender
  end

  # Returns the localized gender
  def localized_gender
    @@gender[female] || '' # I18n.t('application.general.undefined')
  end

  # Handle attached user picture through paperclip plugin
  attr_accessor :avatar_url
  has_attached_file :avatar, :styles => { :big => "128x>", :small => "x45>" },
                    :default_url => "/images/default_:style_avatar.png"
  validates_attachment_size :avatar, :less_than => 5.megabytes
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png']
  before_validation :get_remote_avatar, :if => :avatar_url?
  
  
  # paperclip callback, used to recalculate completeness when uploading an avatar
  after_avatar_post_process :calculate_completeness

  # Return the formatted location of the user
  # TODO conditions in compact form?
  #  - something like this?: [city, country].select{|s|s.try(:any?)}.join(', ')
  def location
    [city, country].select { |s| s.try(:any?) }.collect(&:capitalize).join(', ')
  end

  

  # Self written SQL for querying profiles in echo Connect
  def self.search_profiles(competence, search_term, opts={})
    
    opts[:readonly] = false
    opts[:select] ||= "DISTINCT #{self.table_name}.*, #{User.table_name}.email"
    
    
    # join clauses
    opts[:joins] =  "LEFT JOIN #{User.table_name} ON #{User.table_name}.id = profiles.user_id "
    opts[:joins] << "LEFT JOIN #{Membership.table_name} m  ON #{User.table_name}.id = m.user_id "
    opts[:joins] << User.extaggable_joins_clause
    
    
    # Building the where clause

    # Filtering active users
    opts[:conditions] = ["#{User.table_name}.active = 1"]
    
    # Searching for different competences
    if competence.blank?
      # General search
      searched_fields = ["#{self.table_name}.full_name", "#{self.table_name}.city", "#{self.table_name}.country",
                         "#{self.table_name}.about_me", "#{self.table_name}.motivation", 
                         "#{User.table_name}.email", "m.position", "m.organisation"]
    else
      # Search for a certain competence area
      searched_fields = ["#{self.table_name}.full_name", "#{self.table_name}.city", "#{self.table_name}.country"]
      opts[:conditions] << User.extaggable_filter_by_type(competence)
    end
    search_conditions = searched_fields.map{|field|sanitize_sql(["#{field} LIKE ?", "%#{search_term}%"])}
    search_conditions << User.extaggable_conditions_for_term(search_term||'', 0)
    opts[:conditions] << "(#{search_conditions.join(' OR ')})"
    opts[:conditions] = opts[:conditions].join(" AND ")
    
    # Building the order clause
    opts[:order] = "CASE WHEN #{self.table_name}.completeness >= #{COMPLETENESS_THRESHOLD} THEN 0 ELSE 1 END, " +
                   "CASE WHEN #{self.table_name}.full_name='' THEN 1 ELSE 0 END, " +
                   "#{self.table_name}.full_name, #{User.table_name}.id asc;"
      
    all opts
  end
  
  private
  def avatar_url?
    !self.avatar_url.blank?
  end

  #
  #block of aux functions to support the download of an external profile image
  def get_remote_avatar
    self.avatar = open(avatar_url)
  end
end
