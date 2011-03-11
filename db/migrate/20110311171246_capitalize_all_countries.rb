class CapitalizeAllCountries < ActiveRecord::Migration
  def self.up
    Profile.all.each do |p|
      p.update_attribute :country, p.country.capitalize if p.country
    end
  end

  def self.down
    Profile.all.each do |p|
      p.update_attribute :country, p.country.downcase if p.country
    end
  end
end
