# Copyright (c) 2005 Trevor Squires
# Released under the MIT License.  See the LICENSE file for more details.

# Copy this file to RAILS_ROOT/config/virtual_enumerations.rb
# and configure it accordingly.
ActiveRecord::VirtualEnumerations.define do |config|
  config.define :enum_key, :order => 'key ASC', :table_name => 'enum_keys'
  config.define [:language,:language_level,:web_address_type,:organisation_type,
                 :tag_context,:statement_state,:statement_action,:collaboration_team], :order => 'enum_keys.key ASC', :extends => 'EnumKey' do 
   
   class << def value(arg=Language[I18n.locale].code)
        case arg
        when Symbol
          rval = EnumValue.lookup_code(self.code,arg.id2name)
        when String
          rval = EnumValue.lookup_code(self.code,arg)
        else
          raise TypeError, "#{self.class.name}['#{self.code}'].value(): argument should be a String or a Symbol but got a: #{arg.class.name}"
        end
        rval.nil? ? "" : rval.value 
      end
    end
  end
end