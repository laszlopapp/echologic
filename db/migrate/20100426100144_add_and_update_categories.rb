class AddAndUpdateCategories < ActiveRecord::Migration
  def self.up
      Tag.create!(:value => 'echosocial')
      Tag.create!(:value => 'realprices')
      Tag.find_by_value('echonomyJAM').update_attributes!({:value => 'echonomyjam'})
  end

  def self.down
    Tag.find_by_value('echosocial').delete
    Tag.find_by_value('realprices').delete    
    Tag.find_by_value('echonomyjam').update_attributes!({:value => 'echonomyJAM'})
  end
end
