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
            has_many :subscriptions, :dependent => :destroy, :class_name => 'Subscription', :foreign_key => 'subscribeable_id'
            has_many :subscribers, :class_name => 'User', :finder_sql => 'SELECT DISTINCT * FROM users u ' +
                                                                         'LEFT JOIN subscriptions s ON s.subscriber_id = u.id ' +
                                                                         'WHERE s.subscribeable_id = #{id} '
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
            has_many :subscriptions, :dependent => :destroy, :class_name => 'Subscription', :foreign_key => 'subscriber_id'
            has_many :subscribeables, :class_name => 'StatementNode', :finder_sql => 'SELECT DISTINCT * FROM statement_nodes sn ' +
                                                                                     'LEFT JOIN subscriptions s ON s.subscribeable_id = sn.id ' +
                                                                                     'WHERE s.subscriber_id = #{id} '
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