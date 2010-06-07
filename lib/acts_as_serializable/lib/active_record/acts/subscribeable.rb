module ActiveRecord
  module Acts
    module Subscribeable
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def subscribeable?
          false
        end
        
        
        def acts_as_subscribeable(*args)
          args.flatten! if args
          args.compact! if args
          class_eval do
            has_many :subscriptions, :dependent => :destroy
            has_many :subscribers, :through => :subscriptions
          end
          
          class_eval <<-RUBY
            def self.subscribeable?
              true
            end
            
            def followed_by?(user)
              self.subscribers.include? user
            end
          RUBY
        end
      end
    end
    module Subscriber
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def subscriber?
          false
        end
        
        def acts_as_subscriber(*args)
          args.flatten! if args
          args.compact! if args
          class_eval do
            has_many :subscriptions, :dependent => :destroy
            has_many :subscribeables, :through => :subscriptions
          end
          class_eval <<-RUBY
            def self.subscriber?
              true
            end
            
            def follows?(obj)
              self.subscribeables.include? obj
            end
            
            def find_or_create_subscription_for obj
              subscriptions.find_by_subscribeable_id(obj.id) || Subscription.create(:subscriber => self, :subscribeable => obj)
            end
          RUBY
        end
      end
    end
  end
end