class StatementImage < ActiveRecord::Base
  has_one :statement
  # Handle attached statement image through paperclip plugin
  has_attached_file :image, :styles => { :big => "800x600>", :medium => "170x113>", :small => "x45>" },
                    :default_url => "/images/default_:style_statement_image.png"
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png']

end