class BackgroundInfo < StatementNode
  has_children_of_types
  has_linkable_types :BackgroundInfo

  belongs_to :node_info
  validates_presence_of :node_info
  validates_associated :node_info
  
  #Overwriting of nested set function (hub's make it impossible to level them right)
  def level; parent_node.level + 1; end
    
  class << self
    def new_instance(attributes={})
      attributes[:editorial_state] = StatementState[attributes.delete(:editorial_state_id).to_i] if attributes[:editorial_state_id]
      editorial_state = attributes.delete(:editorial_state)
      if node_info_attrs = attributes.delete(:node_info)
        if info_type = node_info_attrs.delete(:info_type)
          node_info_attrs[:info_type_id] = InfoType[info_type].id
        end
        attributes[:node_info] = NodeInfo.new(node_info_attrs)
      end
      node = self.new(attributes)
      node.set_statement(:editorial_state => editorial_state) if node.statement.nil?
      node
    end
    
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
