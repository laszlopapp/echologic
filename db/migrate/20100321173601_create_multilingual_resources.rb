class CreateMultilingualResources < ActiveRecord::Migration
  def self.up
    create_table :multilingual_resources do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :multilingual_resources
  end
end
