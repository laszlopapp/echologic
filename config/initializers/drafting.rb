require 'drafting_service/drafting_service'
require 'drafting_service/acts_as_incorporable'
require 'drafting_service/acts_as_drafteable'
require 'drafting_service/drafting_info'
require 'drafting_service/test_for_staged_job'
require 'drafting_service/test_for_passed_job'
require 'drafting_service/approval_reminder_mail_job'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Incorporable
ActiveRecord::Base.send :include, ActiveRecord::Acts::Drafteable

if !RAILS_ENV.eql? 'production'
  DraftingService.min_quorum = 50
  DraftingService.min_votes  = 2
  DraftingService.time_ready  = 10.minutes
  DraftingService.time_approved  = 10.minutes
  DraftingService.time_approval_reminder  = 7.minutes
  DraftingService.edit_locking_time  = 1.hours
else
  DraftingService.min_quorum = 50
  DraftingService.min_votes  = 3
  DraftingService.time_ready  = 24.hours
  DraftingService.time_approved  = 24.hours
  DraftingService.time_approval_reminder  = 12.hours
  DraftingService.edit_locking_time  = 1.hours
end