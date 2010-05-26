class SpokenLanguage < ActiveRecord::Base
  belongs_to :user
  
  enum :languages
  enum :levels, :enum_name => :language_levels
  
  include ProfileUpdater
  
  validates_presence_of :user_id
  validates_presence_of :level_id
  validates_presence_of :language_id
  validate_on_create :one_language_instance_per_user
  
  def one_language_instance_per_user 
    errors.add(:user, I18n.t('users.spoken_languages.error_messages.repeated_instance')) if 
      user and language and !SpokenLanguage.first(:conditions => ["user_id = ? and language_id = ?",user.id,language.id]).nil?       
  end
  
  def profile
    self.user.profile
  end
  
end
