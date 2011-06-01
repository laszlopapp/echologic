class StatementData < ActiveRecord::Base
  has_one :statement
  
  has_enumerated :info_type, :class_name => 'InfoType'
  validates_presence_of :info_type_id
  validates_presence_of :info_url # TODO: When there's the possibility to upload files, rethink this
  
  # TODO: This is not used yet! This will be activated when it is possible to update files
#  has_attached_file :image, :default_url => "/images/default_:style_statement_image.png"
#  validates_attachment_size :image, :less_than => 5.megabytes
#  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png', 'doc' ...]
#  before_post_process :image?
#  def image?
#    !(data_content_type =~ /^image.*/).nil?
#  end
  
  def is_youtube_url?
    info_url.match(/.*http:\/\/(\w+\.)?youtube.com\/watch\?v=(\w+).*/)
  end
  
  def youtube_id
    info_url.match("[\?&]v=([^&#]*)")[1]
  end
end
