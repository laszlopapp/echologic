class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      t.string  :subject
      t.text    :text
      t.boolean :default_greeting, :default => true
      t.boolean :default_goodbye, :default => true
      t.timestamps
    end
    
    # Translation table for descriptions
    create_table :newsletter_translations do |t|
      t.integer :newsletter_id
      t.string  :locale
      t.string  :subject
      t.text    :text
    end
  end

  def self.down
    drop_table :newsletters
    drop_table :newsletter_translations
  end
end
