class WebAddress < ActiveRecord::Base

  belongs_to :user
  
  enum :web_addresses
  
  include ProfileUpdater
  
  validates_presence_of :web_address_id, :location, :user_id

  

  
  def profile
    self.user.profile
  end

  

  # Validate if location has valid format

  validates_format_of :location, :with => /^((www\.|http:\/\/)([a-z0-9]*\.)+([a-z]{2,3}){1}(\/[a-z0-9]+)*(\.[a-z0-9]{1,4})?)|(([a-z0-9]+[a-z0-9\.\_\-]*)@[a-z0-9]{1,}[a-z0-9\-\.]*\.[a-z]{2,4})$/i

end
