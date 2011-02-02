class Newsletter < ActiveRecord::Base
  has_many :translations, :class_name => 'NewsletterTranslation'
  translate_columns :title, :text
end
