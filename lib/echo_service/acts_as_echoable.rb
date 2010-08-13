module ActiveRecord
  module Acts
    module Echoable
      def self.included(base)
        base.extend(ClassMethods)
        base.instance_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        def echoable?
          false
        end
      end

      module ClassMethods
        def acts_as_echoable

          class_eval do
            belongs_to :echo
            has_many :user_echos, :foreign_key => 'echo_id', :primary_key => 'echo_id'
            delegate :supporter_count, :visitor_count, :to => :echo
            after_create :author_support
          end


          class_eval do
            # All echoable objects return true by default.
            def echoable?
              true
            end

            ####################################
            # echo methods for visit & support #
            ####################################

            # Records that the given user has visited the echoable.
            #
            # TODO: Please rename to 'visited!'
            def visited!(user)
              EchoService.instance.visited!(self, user)
            end

            # Returns true if the given user has visited the echoable.
            #
            # Please rename to 'visited?'
            def visited?(user)
              EchoService.instance.visited?(self, user)
            end

            # Records that the given user has supported the echoable.
            #
            # TODO: Please rename to 'supported!'
            def supported!(user)
              EchoService.instance.supported!(self, user)
            end

            # Returns true if the given user supports the echoable.
            #
            # TODO: Please rename to 'supported?'
            def supported?(user)
              EchoService.instance.supported?(self, user)
            end

            #TODO: Please implement the opposite method unsupported!(user) here
            def unsupported!(user)
              EchoService.instance.unsupported!(self, user)
            end

            # Returns true if the given user doesn't support the echoable.
            #
            # TODO: Please implement the opposite method unsupported?(user) here
            def unsupported?(user)
              EchoService.instance.unsupported?(self, user)
            end

            #######################
            # Statistical methods #
            #######################

            # Returns the count of users who has visited the echoable.
            def visitor_count
              find_or_create_echo if echo.nil?
              echo.visitor_count
            end

            # Returns the count of users who currently support the echoable.
            def supporter_count
              find_or_create_echo if echo.nil?
              echo.supporter_count
            end

            # Ratio of supporters vs. visitors
            # currently unused (see ratio)
            def supporters_visitors_ratio

              # FIXME: if we want to avoid devision by zero, the check should be made against visitor_count
              if supporter_count == 0
                return 0
              end
              ((supporter_count.to_f / visitor_count.to_f) * 100).to_i
            end


            # Returns the echo belonging to the echoable and creates it if it doesn't exist yet.
            def find_or_create_echo
              if !self.echo_id.nil?
                echo
              else
                echo = create_echo
                save
                echo
              end
            end


            # FIXME: ALL methods below are statement_node specific and should therefore NOT
            #        belong to the general echoable module/plugin.
            #        Please move it to statement_node_echos (being an extension of statement_node).

            public

            # Delegates to 'support_relative_to_siblings'
            def ratio
              support_relative_to_sibblings
            end

            protected

            # Ratio of this statement's supporters relative to the most supported sibbling statement's supporters.
            def support_relative_to_sibblings
              if parent && parent.most_supported_child.try(:supporter_count).to_i > 0
                max_support_count = parent.most_supported_child.supporter_count;
                ((supporter_count.to_f / max_support_count.to_f) * [10*max_support_count, 100].min).to_i
              else
                0
              end
            end

            # Finds the most supported child (used by ratio of entity vs. the most supported sibbling)
            def most_supported_child
              children.by_supporters.first
            end

            # Records the creator's support for the statement.
            def author_support
              if (!self.incorporable? or self.parent.supported?(self.creator)) # and self.echoable? SHOULD I????
                self.supported!(self.creator)
              end
            end

            public
            def supporters
              self.user_echos.map{|ue|ue.user}
            end
          end # --- class_eval


        end
      end
    end
  end
end