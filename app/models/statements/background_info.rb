class BackgroundInfo < StatementNode
  has_children_of_types
  has_linkable_types :BackgroundInfo

  delegate :statement_datas, :external_url, :to => :statement
  
  #Overwriting of nested set function (hub's make it impossible to level them right)
  def level; parent_node.level + 1; end
    
  def info_type
    statement_datas.first.info_type
  end
    
  class << self
    def new_instance(attributes={})
      attributes = filter_attributes(attributes)
      editorial_state = attributes.delete(:editorial_state)
      statement_datas = attributes.delete(:statement_datas) || []
      node = self.new(attributes)
      node.set_statement(:editorial_state => editorial_state, :statement_datas => statement_datas) if node.statement.nil?
      node
    end
    
    def filter_attributes(attributes={})
      attributes = filter_editorial_state(attributes)
      info_type_id = attributes[:info_type] ? InfoType[attributes.delete(:info_type)].id : nil
      if external_url_attrs = attributes.delete(:external_url)
        attributes[:statement_datas] = []
        attributes[:statement_datas] << ExternalUrl.new(external_url_attrs.merge({:info_type_id => info_type_id}))
      end
      attributes
    end
    
    def default_children_types(opts={})
      format_types [[:FollowUpQuestion, true]], opts
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

    def more_data_partial
      'statements/background_data'
    end
  end
end
