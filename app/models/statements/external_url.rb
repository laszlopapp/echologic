class ExternalUrl < StatementData
  validates_presence_of :info_url 
  
  def is_youtube_url?
    info_url.match(/.*http:\/\/(\w+\.)?youtube.com\/watch\?v=(\w+).*/)
  end
  
  def is_vimeo_url?
    info_url.match(/.*http:\/\/(\w+\.)?vimeo.com\/(\d+).*/)
  end
  
  def youtube_id
    info_url.match("[\?&]v=([^&#]*)")[1]
  end
  
  def vimeo_id
    info_url.match("vimeo\.com/(?:.*#|.*/videos/)?([0-9]+)")[1];
  end
end
