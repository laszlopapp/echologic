class AboutItem < ActiveRecord::Base

  # Handle attached item photo through paperclip plugin
  has_attached_file :photo, :styles => { :big => "128x>", :small => "x45>" },
                    :default_url => "/images/default_:style_photo.png"
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png']


  has_enumerated :about_category, :class_name => 'AboutCategory'

  has_many :translations, :class_name => 'AboutItemTranslation'
  translate_columns :responsibility, :description

  validates_numericality_of :index, :greater_than => 0
  validates_presence_of :name, :index

  named_scope :by_index, :order => 'about_items.index ASC'
end
