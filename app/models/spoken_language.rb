class SpokenLanguage < ActiveRecord::Base
  belongs_to :user
  belongs_to :level, :class_name => "EnumKey"
  belongs_to :language, :class_name => "EnumKey"
  
  validates_presence_of :user
  validates_presence_of :level
  validates_presence_of :language
  validate_on_create :one_language_instance_per_user
  
  def one_language_instance_per_user 
    errors.add(:user, I18n.t('users.spoken_languages.error_messages.repeated_instance')) if 
      !SpokenLanguage.first(:conditions => ["user_id = ? and language_id = ?",user.id,language.id]).nil?       
  end
  
end
