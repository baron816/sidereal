class User < ActiveRecord::Base
	has_secure_password
	has_many :user_groups
	has_many :groups, through: :user_groups
	has_many :messages

	after_create do
		find_or_create_group
	end

	geocoded_by :address

	after_validation :geocode

	def find_or_create_group
		group = Group.joins(:users).near(self, 0.5).where(can_join: true, category: self.category).where.not('users.id' => self.id).limit(1)

		if group.any?
			self.groups << group
		else
			Group.create(longitude: self.longitude, latitude: self.latitude, category: self.category).users << self
		end
	end

	def address
		[street, city, state].join(', ')
	end

	def birthday
		Date.new(birth_year, birth_month, birth_day)
	end

	def age
		now = Date.today
		now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
	end
end