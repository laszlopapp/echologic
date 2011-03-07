class CreateShortcutUrls < ActiveRecord::Migration
  def self.up
    create_table :shortcut_urls, :id => false do |t|
      t.string :shortcut, :primary => true
      t.boolean :human_readable
      t.string :base_shortcut
      t.integer :iterator, :default => 0
      t.integer :shortcut_command_id
      t.timestamps
    end
    
    create_table :shortcut_commands do |t|
      t.string :command
    end
  end

  def self.down
    drop_table :shortcut_urls
    drop_table :shortcut_commands
  end
end
