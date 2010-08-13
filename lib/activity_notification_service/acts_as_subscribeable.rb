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
            after_create :create_event

            def create_event
              event_json = self.to_json(:include => {
                                          :statement => {
                                            :include =>  {
                                              :statement_documents => {
                                                :only => [:title, :language_id]
                                              }
                                            }
                                          },
                                          :tao_tags => {
                                            :include => {
                                              :tag => {
                                                :only => :value
                                              }
                                            }
                                          }
                                        },
                                        :only => [:root_id,:parent_id,:type])

              events << Event.new(:event => event_json,
                                :subscribeable => self,
                                :subscribeable_type => self.class.name,
                                :operation => 'new')
            end

            def self.subscribeable?
              true
            end

            def followed_by?(user)
              self.subscriptions.map{|s|s.subscriber}.include? user
            end

            def add_subscriber(subscriber)
              return if subscriber.nil?
              subscription = self.subscriptions.find_by_subscriber_id(subscriber.id) ||
                               Subscription.new(:subscriber => subscriber,
                                                :subscriber_type => subscriber.class.name,
                                                :subscribeable => self,
                                                :subscribeable_type => self.class.name)
              subscriptions << subscription if subscription.new_record?
            end

            def remove_subscriber(subscriber)
              return if subscriber.nil?
              subscription = self.subscriptions.find_by_subscriber_id(subscriber.id)
              subscriptions.delete(subscription) if subscription
            end

            handle_asynchronously :remove_subscriber
            handle_asynchronously :add_subscriber

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