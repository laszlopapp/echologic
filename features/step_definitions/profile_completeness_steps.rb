Given /^I have not filled out the country field$/ do
  @user.country = nil
  @user.save!
  @user.country.should be_nil
end

Then /^my profile should be more complete$/ do
  @user.completeness.should >= @completeness
end

Given /^I know how complete my profile is$/ do
  @completeness = @user.completeness
end
