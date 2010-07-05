class User < ActiveRecord::Base
  include UserExtension::Echo
  
  
  has_many :web_addresses, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  has_many :spoken_languages, :dependent => :destroy, :order => 'level_id asc'
  has_many :tao_tags, :as => :tao, :dependent => :destroy
  has_many :tags, :through => :tao_tags

  has_many :reports, :foreign_key => 'suspect_id'

  named_scope :no_member, :conditions => { :memberships => nil }, :order => :email

  # Every user must have a profile. Profiles are destroyed with the user.
  has_one :profile, :dependent => :destroy

  named_scope :affection_tags, lambda {
  {:joins => [:tao_tags], :conditions => ["tao_tags.context_id = ?", TaoTag.tag_contexts("affection")]}}
  named_scope :engagement_tags, lambda {
  {:joins => [:tao_tags], :conditions => ["tao_tags.context_id = ?", TaoTag.tag_contexts("engagement")]}}
  named_scope :expertise_tags, lambda {
  {:joins => [:tao_tags], :conditions => ["tao_tags.context_id = ?", TaoTag.tag_contexts("expertise")]}}
  named_scope :decision_making_tags, lambda {
  {:joins => [:tao_tags], :conditions => ["tao_tags.context_id = ?", TaoTag.tag_contexts("decision_making")]}}
 
  
  # TODO add attr_accessible :active if needed.
  #attr_accessible :active

  # Authlogic plugin to do authentication
  acts_as_authentic do |c|
#    c.logged_in_timeout = 10.minutes#1.hour
    c.validates_length_of_password_field_options = {:on => :update, :minimum => 4, :if => :has_no_credentials?}
    c.validates_length_of_password_confirmation_field_options = {:on => :update, :minimum => 4, :if => :has_no_credentials?}
  end

  # acl9 plugin to do authorization
  acts_as_authorization_subject
  acts_as_authorization_object

  # we need to make sure that either a password or openid gets set
  # when the user activates his account
  def has_no_credentials?
    self.crypted_password.blank? && self.openid_identifier.blank?
  end

  # Return true if user is activated.
  def active?
    active
  end

  # handy interfacing
  def is_author?(other)
    other.author == self
  end

  # Signup process before activation: get login name and email, ensure to not
  # handle with sessions.
  def signup!(params)
    self.profile.first_name = params[:user][:profile][:first_name]
    self.profile.last_name  = params[:user][:profile][:last_name]
    self.email              = params[:user][:email]
    save_without_session_maintenance
  end

  # Returns the display name of the user
  # TODO Depricated. Use user.profile.full_name
  #  Changed for mailer model - anywhere else used?
  def display_name()
    self.profile.first_name + " " + self.profile.last_name;
  end

  # Activation process. Set user active and add its password and openID and
  # save with session handling afterwards.
  def activate!(params)
    self.active = true
    self.password = params[:user][:password]
    self.password_confirmation = params[:user][:password_confirmation]
    self.openid_identifier = params[:user][:openid_identifier]
    save
  end

  # Uses mailer to deliver activation instructions
  def deliver_activation_instructions!
    reset_perishable_token!
    Mailer.deliver_activation_instructions(self)
  end

  # Uses mailer to deliver activation confirmation
  def deliver_activation_confirmation!
    reset_perishable_token!
    Mailer.deliver_activation_confirmation(self)
  end

  # Send a password reset email through mailer
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Mailer.deliver_password_reset_instructions(self)
  end

  ##
  ## PERMISSIONS
  ##

  # the given `statement_node' is ignored for now, but we need it later
  # when we enable editing for users.
  def may_edit?
    has_role?(:editor) or has_role?(:admin)
  end

  def may_delete?(statement_node)
    has_role?(:admin)
  end

  ##
  ## SPOKEN LANGUAGES
  ##

  # returns an array with the actual language_ids of the users spoken languages (used to find the right translations)
  def spoken_language_ids
    a = []
    SpokenLanguage.language_levels.each do |level|
      a << self.spoken_languages.select{|sp| sp.level.eql?(level)}
    end
    a.flatten.map(&:language_id)
  end

  def mother_tongues
    self.spoken_languages.select{|sp| sp.level.code == 'mother_tongue'}.collect{|sp| sp.language}
  end

  ##
  ## CONCERNMENTS (TAGS)
  ##

  def add_tags(tags, opts = {})
    self.tao_tags << TaoTag.create_for(tags, opts[:language_id], {:tao_id => self.id, :tao_type => self.class.name, :context_id => opts[:context_id]})
  end

  def delete_tags(tags)
    self.tao_tags.each {|tao_tag| tao_tag.destroy if tags.include?(tao_tag.tag.value)}
  end
end
