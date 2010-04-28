class AddAndUpdateCategories < ActiveRecord::Migration
  def self.up
    Tag.create!(:value => 'echosocial')
    Tag.create!(:value => 'realprices')
    t = Tag.find_by_value('echonomyJAM')
    t.update_attributes!({:value => 'echonomyjam'}) unless t.nil?
  end

  def self.down
    Tag.find_by_value('echosocial').delete
    Tag.find_by_value('realprices').delete
    t = Tag.find_by_value('echonomyjam')
    t.update_attributes!({:value => 'echonomyJAM'}) unless t.nil?
  end
end
