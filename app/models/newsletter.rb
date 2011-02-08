class Newsletter < ActiveRecord::Base
  has_many :translations, :class_name => 'NewsletterTranslation'
  translate_columns :subject, :text
end
