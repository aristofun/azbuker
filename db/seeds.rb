# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)
#
# Never run this in production :)
#
usr = User.create!(:email => "azbukeradmin@example.com", :password => "123456", :agreement => "1", :cityid => -1) do |us|
  us.confirmed_at = 1.second.ago
end
usr.admin = true
usr.save!

User.create!(:email => "azbukeruser@example.com", :password => "123456", :agreement => "1", :cityid => -1) do |us|
  us.confirmed_at = 1.second.ago
end


