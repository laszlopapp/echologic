class SpokenLanguage < ActiveRecord::Base
  include ProfileUpdater
  
  belongs_to :user
  
  has_enumerated :language, :class_name => 'Language'
  has_enumerated :level, :class_name => 'LanguageLevel'


  delegate :percent_completed, :to => :user

  validates_presence_of :user
  validates_presence_of :level
  validates_presence_of :language
  validate_on_create :one_language_instance_per_user

  def one_language_instance_per_user
    errors.add(:user, I18n.t('users.spoken_languages.error_messages.repeated_instance')) if
      user and language and !SpokenLanguage.first(:conditions => ["user_id = ? and language_id = ?",user.id,language.id]).nil?
  end
end
