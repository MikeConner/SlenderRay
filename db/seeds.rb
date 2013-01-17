# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Role::ROLES.each do |role|
  Role.create!(:name => role)
end

Protocol.create(:name => 'Reduce Pain', :frequency => 254)
Protocol.create(:name => 'Promote Healing', :frequency => 484)
Protocol.create(:name => 'Reduce Inflammation', :frequency => 610)
Protocol.create(:name => 'Repair Bone', :frequency => 692)
Protocol.create(:name => 'Relax Muscles', :frequency => 787)
Protocol.create(:name => 'Decrease Swelling', :frequency => 802)
Protocol.create(:name => 'Enhance Immunity', :frequency => 880)
Protocol.create(:name => 'Energize Cells', :frequency => 15550)
