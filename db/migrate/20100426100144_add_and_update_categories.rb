class AddAndUpdateCategories < ActiveRecord::Migration
  def self.up
    Tag.create!(:value => 'echosocial')
    Tag.create!(:value => 'realprices')
    t = Tag.find_by_value('echonomyJAM')
    t.value = String.new('echonomyjam')
    t.save
  end

  def self.down
    Tag.find_by_value('echosocial').delete
    Tag.find_by_value('realprices').delete    
    t = Tag.find_by_value('echonomyjam')
    t.value = String.new('echonomyJAM')
    t.save
  end
end
