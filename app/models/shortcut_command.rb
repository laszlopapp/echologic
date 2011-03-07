class ShortcutCommand < ActiveRecord::Base
  has_many :shortcut_urls
  
  validates_uniqueness_of :command
end
