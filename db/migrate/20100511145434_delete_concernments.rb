class DeleteConcernments < ActiveRecord::Migration
  def self.up    
    Concernment.all.each do |concernment|
      user = User.find(concernment.user_id)
      tag = Tag.find(concernment.tag_id)
      context_key = concernment.sort+1
      tao_tag = TaoTag.create(:tag_id => tag.id, :tao_id => user.id, :tao_type => 'User', :context_id => EnumKey.find_by_key_and_enum_name(context_key,"tag_contexts"))
    end
    drop_table :concernments
  end

  def self.down
    create_table :concernments do |t|
        t.integer :user_id
        t.integer :tag_id
        t.integer :sort
  
        t.timestamps
      end
      add_index :concernments, [:user_id, :sort]
      add_index :concernments, [:sort]
    end
end
