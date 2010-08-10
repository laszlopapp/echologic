module UserExtension
  module Echo
    def self.included(base)
      base.instance_eval do
        has_many :user_echos
        has_many :echos, :through => :user_echos
  
        # FIXME: statement specific and should therefore be removed here!
        has_many :echoed_statements, :through => :user_echos, :source => :statement_node
      end
    end
  end
end

