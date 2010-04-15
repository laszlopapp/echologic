class Profile < ActiveRecord::Base

  # Every profile has to belong to a user.
  belongs_to :user,       :dependent => :destroy
  has_many :web_addresses, :through => :user
  has_many :memberships,  :through => :user
  has_many :concernments, :through => :user
  has_many :spoken_languages, :through => :user

  validates_presence_of :user_id
  validates_length_of :about_me, :maximum => 1024, :allow_nil => true
  validates_length_of :motivation, :maximum => 1024, :allow_nil => true
  
 
  include ProfileExtension::Completeness


  # named scope, only returning profiles with 'show_profile' flag set to true
  # currently this flag is true for alle users before release 0.5 and everyone who ever had more then 50% of his profile filled
  # FIXME: this scope isn't used, because the current profile search implementation doesn't work with additional scopes
  named_scope :published, :conditions => { :show_profile => 1 }  
 
  # callback for paperclip
 
  
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
  has_attached_file :avatar, :styles => { :big => "128x>", :small => "x45>" },
                    :default_url => "/images/default_:style_avatar.png"
  validates_attachment_size :avatar, :less_than => 5.megabytes
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png']
  # paperclip callback, used to recalculate completeness when uploading an avatar
  after_avatar_post_process :calculate_completeness

  # Return the full name of the user composed of first- and lastname
  def full_name
    [first_name, last_name].select { |s| s.try(:any?) }.join(' ')
  end

  # Return the formatted location of the user
  # TODO conditions in compact form?
  #  - something like this?: [city, country].select{|s|s.try(:any?)}.join(', ')
  def location
    [city, country].select { |s| s.try(:any?) }.join(', ')
  end

  # Return the first membership. If none is set return empty-string.
  def first_membership
    return "" if memberships.blank?
    "#{memberships.first.organisation} - #{memberships.first.position}"
  end

end
