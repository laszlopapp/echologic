class DraftingInfo < ActiveRecord::Base
  
  validates_numericality_of :times_passed
  validates_inclusion_of :times_passed, :in => 0..2
end
