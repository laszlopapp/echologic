class UserEcho < ActiveRecord::Base
  belongs_to :echo
  belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'
  belongs_to :statement_node, :foreign_key => 'echo_id', :primary_key => 'echo_id'

  validates_presence_of :user_id, :echo_id

  named_scope :visited, lambda { { :conditions => { :visited => true } } }
  named_scope :supported, lambda { { :conditions => { :supported => true } } }

  named_scope :for_user, lambda { |user_id| { :conditions => { :user_id => user_id } } }
  named_scope :for_echo, lambda { |echo_id| {:conditions => {:echo_id => echo_id}}}

  class << self

    # Finds the UserEcho based on the given echo and user in the options hash and
    # updates it's attributes with the remaining options.
    # If the UserEcho object doesn't exist yet, it gets created.
    def create_or_update!(options)
      user_echo = find(:first,
                       :conditions => {:user_id => options[:user].id,
                                       :echo_id => options[:echo].id })
      user_echo ? user_echo.update_attributes!(options) : user_echo = create!(options)
      user_echo
    end
  end
end
