class ChangeFirstAndLastNameToFullNameAndAddDesiredEmail < ActiveRecord::Migration
  def self.up
    add_column :profiles, :full_name, :string
    Profile.all.each do |profile|
      profile.update_attribute :full_name, [profile.first_name, profile.last_name].reject{|s| s.blank? }.join(' ') if profile.user
    end
    remove_column :profiles, :first_name, :last_name
    add_column :users, :desired_email, :string
    change_column :users, :email, :string, :null => true
  end

  def self.down
    add_column :profiles, :first_name, :string, :null => false
    add_column :profiles, :last_name, :string, :null => false
    Profile.all.each do |profile|
      names = profile.full_name.split(' ')
      profile.first_name = names[0]
      profile.last_name = names[1] if names[1]
      profile.save
    end
    remove_column :profiles, :full_name
    remove_column :users, :desired_email
    change_column :users, :email, :string, :null => false
  end
end
