Given /^I have the following spoken languages:$/ do |table|
  table.hashes.each do |hash|
    hash[:language] = EnumValue.find_by_value(hash[:language]).enum_key
    hash[:level] = EnumValue.find_by_value(hash[:level]).enum_key
    hash[:user] = @user
    SpokenLanguage.create!(hash)
  end
end

# Remove all web addresses.
Given /^I have no spoken languages$/ do
  @user.spoken_languages.destroy_all
end

Then /^I should have the following spoken languages:$/ do |table|
  table.hashes.each do |hash|
    hash[:language_id] = EnumValue.find_by_value(hash[:language]).enum_key.id
    hash[:level_id] = EnumValue.find_by_value(hash[:level]).enum_key.id
    assert !@user.spoken_languages.find_by_language_id_and_level_id(hash[:language_id],hash[:level_id]).nil?
  end
end