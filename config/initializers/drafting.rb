require 'drafting_service/drafting_service'
require 'drafting_service/acts_as_incorporable'
require 'drafting_service/acts_as_drafteable'
require 'drafting_service/drafting_info'
require 'drafting_service/test_for_staged_job'
require 'drafting_service/test_for_passed_job'
require 'drafting_service/approval_reminder_mail_job'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Incorporable
ActiveRecord::Base.send :include, ActiveRecord::Acts::Drafteable

DraftingService.min_quorum = 50
DraftingService.min_votes  = 5
DraftingService.time_ready  = Time.now.advance(:hours => 10)
DraftingService.time_approved  = Time.now.advance(:hours => 10)
DraftingService.time_approval_reminder  = Time.now.advance(:hours => 6)