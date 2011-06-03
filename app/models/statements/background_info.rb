class BackgroundInfo < StatementNode
  has_children_of_types
  has_linkable_types :BackgroundInfo

  delegate :statement_datas, :info_type, :external_url, :to => :statement
  
  #Overwriting of nested set function (hub's make it impossible to level them right)
  def level; parent_node.level + 1; end
    
  class << self
    
    # Aux Function: generates new instance
    # loads statement datas as well (and the info type (article, paper, video, etc...)) 
    def new_instance(attributes={})
      attributes = filter_attributes(attributes)
      editorial_state = attributes.delete(:editorial_state)
      statement_datas = attributes.delete(:statement_datas) || []
      info_type_id = attributes.delete(:info_type_id)
      node = self.new(attributes)
      node.set_statement(:editorial_state => editorial_state, :statement_datas => statement_datas, :info_type_id => info_type_id) if node.statement.nil?
      node
    end
    
    # Aux function: rewrites the attributes hash for it to be valid on the act of creating a new background info
    def filter_attributes(attributes={})
      attributes = filter_editorial_state(attributes)
      # info_type comes as a label ; we must get the info type through this label
      attributes[:info_type_id] = attributes[:info_type] ? InfoType[attributes.delete(:info_type)].id : nil
      attributes[:statement_datas] = []
      if external_url_attrs = attributes.delete(:external_url)
        attributes[:statement_datas] << ExternalUrl.new(external_url_attrs)
      end
      # TODO: Add here the external files that might be uploaded
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
    
    # Aux Function: Checks if node has more data to show or load
    def has_more_data?
      true
    end

    def more_data_partial
      'statements/background_data'
    end
  end
end
