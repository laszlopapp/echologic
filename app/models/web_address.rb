class WebAddress < ActiveRecord::Base
  include ProfileUpdater
  belongs_to :user
  delegate :percent_completed, :to => :user

  has_enumerated :type, :class_name => 'WebAddressType'

  validates_presence_of :type_id, :address, :user_id
  validates_format_of :address, :with => /^(?:(?#Protocol)(?:(?:ht|f)tp(?:s?)\:\/\/)|(?:www\.)){1,1}(?#Username:Password)(?:\w+:\w+@)?(?#Subdomains)(?:(?:[-\w]+\.)+(?#TopLevel Domains)(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|[a-z]{2}))(?#Port)(?::[\d]{1,5})?(?#Directories)(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?#Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?#Anchor)(?:#(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?$/i, :unless => :email?
  validates_format_of :address, :with => /^([a-z0-9!\#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!\#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|[a-z]{2}))$/i, :if => :email?

  def email?
    !self.type.nil? and self.type.code.eql?("email")
  end
end
