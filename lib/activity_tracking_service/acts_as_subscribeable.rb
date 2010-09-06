module ActiveRecord
  module Acts
    module Subscribeable

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def self.subscribeable?
          false
        end


        def acts_as_subscribeable(*args)
          args.flatten! if args
          args.compact! if args
          class_eval do
            has_many :subscriptions,
                     :as => :subscribeable,
                     :dependent => :destroy,
                     :class_name => 'Subscription',
                     :foreign_key => 'subscribeable_id'

            has_many :subscribers,
                     :class_name => 'User',
                     :finder_sql => 'SELECT DISTINCT * FROM users u ' +
                                    'LEFT JOIN subscriptions s ON s.subscriber_id = u.id ' +
                                    'WHERE s.subscribeable_id = #{id}'

            has_many :events, :as => :subscribeable

            after_create :created_event

            def created_event
              EchoService.instance.created(self)
            end

            def self.subscribeable?
              true
            end

            def followed_by?(user)
              self.subscriptions.map{|s|s.subscriber}.include? user
            end
          end # --- class_eval
        end
      end
    end


    module Subscriber
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def self.subscriber?
          false
        end

        def acts_as_subscriber(*args)
          args.flatten! if args
          args.compact! if args

          class_eval do
            has_many :subscriptions,
                     :as => :subscriber,
                     :dependent => :destroy,
                     :class_name => 'Subscription',
                     :foreign_key => 'subscriber_id'

            has_many :subscribeables,
                     :class_name => 'StatementNode',
                     :finder_sql => 'SELECT DISTINCT * FROM statement_nodes sn ' +
                                    'LEFT JOIN subscriptions s ON s.subscribeable_id = sn.id ' +
                                    'WHERE s.subscriber_id = #{id}'

            def self.subscriber?
              true
            end

            def follows?(obj)
              self.subscriptions.map{|s|s.subscribeable}.include? obj
            end

            def find_or_create_subscription_for(obj)
              s = subscriptions.find_by_subscribeable_id(obj.id) ||
                    Subscription.create(:subscriber => self,
                                        :subscriber_type => self.class.name,
                                        :subscribeable => obj,
                                        :subscribeable_type => obj.class.name)
            end

            def delete_subscription_for(obj)
              subscription = subscriptions.find_by_subscribeable_id(obj.id)
              subscription.destroy if subscription
            end
          end # --- class_eval

        end
      end
    end
  end
end