class FillCreatorIdForFuqs < ActiveRecord::Migration
  def self.up
    FollowUpQuestion.all.each do |fuq|
      fuq.update_attribute :creator, fuq.question.creator
    end
  end

  def self.down
    FollowUpQuestion.all.each do |fuq|
      fuq.update_attribute :creator, nil
    end
  end
end
