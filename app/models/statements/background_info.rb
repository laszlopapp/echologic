class BackgroundInfo < StatementNode
  has_children_of_types
  has_linkable_types :BackgroundInfo

  delegate :statement_data, :info_type, :to => :statement
  
  #Overwriting of nested set function (hub's make it impossible to level them right)
  def level; parent_node.level + 1; end
    
  class << self
    def new_instance(attributes={})
      attributes = filter_attributes(attributes)
      editorial_state = attributes.delete(:editorial_state)
      statement_data = attributes.delete(:statement_data)
      node = self.new(attributes)
      node.set_statement(:editorial_state => editorial_state, :statement_data => statement_data) if node.statement.nil?
      node
    end
    
    def filter_attributes(attributes={})
      attributes = filter_editorial_state(attributes)
      if statement_data_attrs = attributes.delete(:statement_data)
        if info_type = statement_data_attrs.delete(:info_type)
          statement_data_attrs[:info_type_id] = InfoType[info_type].id
        end
        attributes[:statement_data] = StatementData.new(statement_data_attrs)
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
    
    def has_more_data?
      true
    end
  end
end
