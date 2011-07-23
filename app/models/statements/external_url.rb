class ExternalUrl < StatementData
  validates_presence_of :info_url
  validates_format_of :info_url, :with => /^(?:(?#Protocol)(?:(?:ht|f)tp(?:s?)\:\/\/)|(?:www\.)){1,1}(?#Username:Password)(?:\w+:\w+@)?(?#Subdomains)(?:(?:[-\w]+\.)+(?#TopLevel Domains)(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|[a-z]{2}))(?#Port)(?::[\d]{1,5})?(?#Directories)(?:(?:(?:\/(?:[-\w~!$+|.,=:]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?#Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?#Anchor)(?:#(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?$/i
  
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
