require 'echo_service/echo_service'
require 'activity_tracking_service/activity_tracking_service'

#observers
EchoService.instance.add_observer(DraftingService.instance)
#EchoService.instance.add_observer(ActivityTrackingService.instance)