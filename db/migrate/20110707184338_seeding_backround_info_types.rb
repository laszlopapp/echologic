class SeedingBackroundInfoTypes < ActiveRecord::Migration
  def self.up
    Rake::Task['db:seed'].invoke
  end

  def self.down
  end
end
