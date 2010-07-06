class Membership < ActiveRecord::Base
  include ProfileUpdater
  
  
  belongs_to :user
  delegate :percent_completed, :to => :user
  
  validates_presence_of :organisation, :position, :user_id
end
