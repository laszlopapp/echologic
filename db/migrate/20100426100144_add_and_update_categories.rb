class AddAndUpdateCategories < ActiveRecord::Migration
  def self.up
    Tag.create!(:value => 'echosocial')
    Tag.create!(:value => 'realprices')
#    t = Tag.find_by_value('echonomyJAM')
##    t.value = 'echonomyjamx'
##    t.save
##    t = Tag.find_by_value('echonomyjamx')
#    t.update_attributes!({:value => 'echonomyjam'})
#    t.save

    sql = ActiveRecord::Base.connection();
    
    sql.begin_db_transaction    
    sql.update "UPDATE tags SET value='echonomyjam' WHERE value='echonomyJAM'";
    sql.commit_db_transaction

  end

  def self.down
    Tag.find_by_value('echosocial').delete
    Tag.find_by_value('realprices').delete    
    t = Tag.find_by_value('echonomyjam')
     t.value.replace('echonomyJAMx')
    t.value.replace('echonomyJAM')
    t.save
  end
end
