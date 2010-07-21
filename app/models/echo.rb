class Echo < ActiveRecord::Base

  # FIXME: take polymorphism into account (should work with act_as_echoable for arbitrary models!)
  has_one :statement_node

  has_many :user_echos
  before_save :update_counter


  def update_counter!
    update_counter
    save!
  end

  def update_counter
    write_attribute :visitor_count,
                    user_echos.count(:conditions => { :visited => true })
    write_attribute :supporter_count,
                    user_echos.count(:conditions => { :supported => true })
  end

end
