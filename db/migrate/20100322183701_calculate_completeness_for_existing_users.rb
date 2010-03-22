class CalculateCompletenessForExistingUsers < ActiveRecord::Migration
  def self.up
    Profile.all.each do |p|
      p.calculate_completeness
      p.save!
    end
  end

  def self.down
  end
end
