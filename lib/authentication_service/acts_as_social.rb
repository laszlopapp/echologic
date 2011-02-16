module ActiveRecord
  module Acts
    module Social
      
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_social(*args)
          
          class_eval do
            has_many :rpx_identifiers, :class_name => 'RPXIdentifier', :dependent => :destroy
          
            #
            # test if account it using RPX authentication
            #
            def using_rpx?
              !rpx_identifiers.empty?
            end
            
            # adds RPX identification to the instance.
            # Abstracts how the RPX identifier is added to allow for multiplicity of underlying implementations
            #
            def add_rpx_identifier( rpx_id, rpx_provider_name )
              self.rpx_identifiers.build(:identifier => rpx_id, :provider_name => rpx_provider_name )
            end
        
            # Checks if given identifier is an identity for this account
            #
            def identified_by?( id )
              self.rpx_identifiers.find_by_identifier( id )
            end


          
            class << self
              #
              # Add custom find_by_rpx_identifier class method
              #
              def find_by_rpx_identifier(id)
                identifier = RPXIdentifier.find_by_identifier(id)
                if identifier.nil?
                  if self.column_names.include? 'rpx_identifier'
                    # check for authentication using <=1.0.4, migrate identifier to rpx_identifiers table
                    user = self.find( :first, :conditions => [ "rpx_identifier = ?", id ] )
                    unless user.nil?
                      user.add_rpx_identifier( id, 'Unknown' )
                    end
                    return user
                  else
                    return nil
                  end
                else
                  identifier.send( self.methods.include?(:class_name) ? self.class_name.downcase : self.to_s.classify.downcase )
                end
              end
              
              
            end
          end
        end
      end
    end
  end
end