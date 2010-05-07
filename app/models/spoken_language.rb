class SpokenLanguage < ActiveRecord::Base
  belongs_to :user
  belongs_to :level, :class_name => "EnumKey", :foreign_key => :level_id
  belongs_to :language, :class_name => "EnumKey", :foreign_key => :language_id
  
  include ProfileUpdater
  
  validates_presence_of :user
  validates_presence_of :level
  validates_presence_of :language
  validate_on_create :one_language_instance_per_user
  
  def one_language_instance_per_user 
    errors.add(:user, I18n.t('users.spoken_languages.error_messages.repeated_instance')) if 
      user and language and !SpokenLanguage.first(:conditions => ["user_id = ? and language_id = ?",user.id,language.id]).nil?       
  end
  
  def profile
    self.user.profile
  end
  
end
