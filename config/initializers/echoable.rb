require 'echo_service/user_extension_echo'
require 'echo_service/echo'
require 'echo_service/user_echo'
require 'echo_service/acts_as_echoable'
#require 'echo_service/echo_service'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Echoable
EchoService.instance.add_observer(DraftingService.instance)

