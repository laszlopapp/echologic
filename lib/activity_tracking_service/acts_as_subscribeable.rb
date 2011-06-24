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
                     :dependent => :destroy

            has_many :events,
                     :as => :subscribeable,
                     :dependent => :destroy

            has_many :subscribers,
                     :class_name => 'User',
                     :finder_sql => 'SELECT DISTINCT * FROM users u ' +
                                    'LEFT JOIN subscriptions s ON s.subscriber_id = u.id ' +
                                    'WHERE s.subscribeable_id = #{id}'

            after_destroy :destroy_events

            #
            # Destroys Subscriptions and Events which would become orphaned after deleting this statement.
            #
            def destroy_events
              Event.destroy_all("event LIKE '%\"id\":#{self.target_id}%' AND event LIKE '%\"type\":\"#{self.class.name.underscore}\"%'")
            end

            def self.subscribeable?
              true
            end

            def followed_by?(user)
              self.subscribers.include? user
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
            has_one :subscriber_data,
                    :as => :subscriber,
                    :dependent => :destroy

            has_many :subscriptions,
                     :as => :subscriber,
                     :dependent => :destroy

            has_many :subscribeables,
                     :class_name => 'StatementNode',
                     :finder_sql => 'SELECT DISTINCT * FROM statement_nodes sn ' +
                                    'LEFT JOIN subscriptions s ON s.subscribeable_id = sn.id ' +
                                    'WHERE s.subscriber_id = #{id}'

            after_create :initialize_subscriber_data

            def initialize_subscriber_data
              subscriber_data = SubscriberData.create(:subscriber => self, :last_processed_event => Event.last)
            end

            delegate :last_processed_event,
                     :last_processed_event_id, :to => :subscriber_data

            def self.subscriber?
              true
            end

            def follows?(obj)
              self.subscribeables.include? obj
            end
          end # --- class_eval
        end
      end
    end
  end
end