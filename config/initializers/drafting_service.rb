require 'drafting_service'
require 'acts_as_incorporable'
require 'acts_as_draftable'
require 'drafting_info'
require 'test_for_staged_job'
require 'test_for_passed_job'
require 'approval_reminder_mail_job'
require 'echo_service/echo_service'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Incorporable
ActiveRecord::Base.send :include, ActiveRecord::Acts::Draftable

if !RAILS_ENV.eql? 'production'
  DraftingService.min_quorum = 50
  DraftingService.min_votes = 2
  DraftingService.time_ready = 2.minutes
  DraftingService.time_approved = 3.minutes
  DraftingService.time_approval_reminder = 2.minutes
else
  DraftingService.min_quorum = 50
  DraftingService.min_votes = 2
  DraftingService.time_ready = 24.hours
  DraftingService.time_approved = 24.hours
  DraftingService.time_approval_reminder = 18.hours
end

# Observers
EchoService.instance.add_observer(DraftingService.instance)
