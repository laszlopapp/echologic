
Given /^I have no concernments$/ do
  @user.tao_tags.destroy_all
end

Then /^I should have ([0-9]+) concernments$/ do |count|
  @user.tao_tags.count.should == count.to_i
end
