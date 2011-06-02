class ExternalUrl < StatementData
  validates_presence_of :info_url 
  
  def is_youtube_url?
    info_url.match(/.*http:\/\/(\w+\.)?youtube.com\/watch\?v=(\w+).*/)
  end
  
  def youtube_id
    info_url.match("[\?&]v=([^&#]*)")[1]
  end
end
