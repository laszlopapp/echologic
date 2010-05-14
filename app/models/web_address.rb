class WebAddress < ActiveRecord::Base

  belongs_to :user

  enum :web_address_types, :name => :web_address_types

  include ProfileUpdater

  validates_presence_of :web_address_type_id, :address, :user_id

  validates_format_of :address, :with => /^(?#Protocol)(?:(?:ht|f)tp(?:s?)\:\/\/)?(?#Username:Password)(?:\w+:\w+@)?(?#Subdomains)(?:(?:[-\w]+\.)+(?#TopLevel Domains)(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|[a-z]{2}))(?#Port)(?::[\d]{1,5})?(?#Directories)(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?#Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?#Anchor)(?:#(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?$/i, :unless => :email?
  validates_format_of :address, :with => /^([a-z0-9!\#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!\#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|[a-z]{2}))$/i, :if => :email?



  def profile
    self.user.profile
  end

  def email?
    !self.web_address_type.nil? and self.web_address_type.code.eql?("email")
  end
end
