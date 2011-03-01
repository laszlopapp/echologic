class PendingAction < ActiveRecord::Base
  include UUIDHelper
  belongs_to :user
  set_primary_key 'uuid'
  
  
end
