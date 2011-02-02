class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      t.string  :title
      t.text    :text
      t.timestamps
    end
    
    # Translation table for descriptions
    create_table :newletter_translations do |t|
      t.integer :newsletter_id
      t.string  :locale
      t.string  :title
      t.text    :text
    end
  end

  def self.down
    drop_table :newsletters
    drop_table :newletter_translations
  end
end
