class AddAndUpdateCategories < ActiveRecord::Migration
  def self.up
      Tag.create!(:value => 'echosocial')
      Tag.create!(:value => 'realprices')
  end

  def self.down
    Tag.find_by_value('echosocial').delete
    Tag.find_by_value('realprices').delete    
  end
end
