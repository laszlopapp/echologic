class BackgroundInfo < StatementNode
  has_children_of_types
  has_linkable_types :BackgroundInfo
  
  #Overwriting of nested set function (hub's make it impossible to level them right)
  def level; parent_node.level + 1; end
    
  class << self
    def default_children_types(opts={})
      []
    end
    
    def support_tag
      "recommend"
    end
  
    def unsupport_tag
      "unrecommend"
    end
  end
end
