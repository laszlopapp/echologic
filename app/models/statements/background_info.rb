class BackgroundInfo < StatementNode
  has_children_of_types
  has_linkable_types :BackgroundInfo

  belongs_to :node_info
  validates_presence_of :node_info
  validates_associated :node_info
  
  delegate :info_type, :to => :node_info
  
  #Overwriting of nested set function (hub's make it impossible to level them right)
  def level; parent_node.level + 1; end
    
  class << self
    def new_instance(attributes={})
      attributes = filter_attributes(attributes)
      editorial_state = attributes.delete(:editorial_state)
      node = self.new(attributes)
      node.set_statement(:editorial_state => editorial_state) if node.statement.nil?
      node
    end
    
    def filter_attributes(attributes={})
      attributes = filter_editorial_state(attributes)
      if node_info_attrs = attributes.delete(:node_info)
        if info_type = node_info_attrs.delete(:info_type)
          node_info_attrs[:info_type_id] = InfoType[info_type].id
        end
        attributes[:node_info] = NodeInfo.new(node_info_attrs)
      end
      attributes
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
