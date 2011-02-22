require 'social_service/acts_as_social'
require 'social_service/social_service'
require 'social_service/rpx_service'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Social

SocialService.instance.service = RpxService.new(RPX_API_KEY, "https://#{RPX_APP_NAME}", nil)
SocialService.instance.social_providers=%w(facebook twitter yahoo linked_in google)