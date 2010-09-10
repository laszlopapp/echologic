# Copyright (c) 2005 Trevor Squires
# Released under the MIT License.  See the LICENSE file for more details.

# Copy this file to RAILS_ROOT/config/virtual_enumerations.rb
# and configure it accordingly.
ActiveRecord::VirtualEnumerations.define do |config|
  config.define :enum_key, :order => 'key ASC', :table_name => 'enum_keys'
  config.define [:language,:language_level,:web_address_type,:organisation_type,
                 :tag_context,:statement_state,:statement_action], :order => 'enum_keys.key ASC', :extends => 'EnumKey'
end