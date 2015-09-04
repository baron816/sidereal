class Group < ActiveRecord::Base
	has_many :user_groups
	has_many :users, through: :user_groups
	has_many :messages
	has_many :notifications, as: :notifiable
	has_many :activities
	has_many :drop_user_votes
	has_many :expand_group_votes

	reverse_geocoded_by :latitude, :longitude

	before_create do
		name_group
	end

	scope :open_groups, -> { where(can_join: true) }
	scope :category_groups, ->(category) { where(category: category) }
	scope :excluded_users, ->(friend_ids) { where.not(id: user_friend_group_ids(friend_ids)) }
	scope :non_former_groups, ->(group_ids) { where.not(id: group_ids) }
	scope :degree_groups, ->(degree) { where(degree: degree) }
	scope :ready_groups, -> { where(ready_to_expand: true) }

	def self.search(params)
		self.open_groups.category_groups(params[:category]).excluded_users(params[:friend_ids]).degree_groups(1).near([params[:latitude], params[:longitude]], 0.5).non_former_groups(params[:group_ids])[0]
	end

	def future_activities
	  activities.future_activities
	end

	def check_space
		if users_count == user_limit - 1 && self.can_join != true
			self.can_join = true
			save
		elsif users_count == user_limit && self.can_join != false
			self.can_join = false
			save
		end
	end

	def drop_user(user)
		users.delete(user)
		user.add_dropped_group(id)
		drop_user_votes.delete_all_votes_from_voter(user)
		check_space
		self.delete if users.empty?
	end

	def kick_user(user)
		drop_user(user) if user.group_drop_votes_count(self) >= 3
	end

	def expand_group
	  group = find_mergable_group
		new_group = nil

		if group
			new_group = Group.create(longitude: longitude, latitude: latitude, category: category, user_limit: new_group_user_limit, can_join: false, degree: new_degree)
			new_group.users << (users + group.users)
			group.ready_to_expand = false
			group.has_expanded, self.has_expanded = true, true
			save
		else
			self.ready_to_expand = true
			save
		end
		expand_group_votes.delete_all

		new_group
	end

	def ripe_for_expansion?
	  aged?(degree.month) && well_attended_activity_count >= 4 && can_join == false && has_expanded == false
	end

	def voted_to_expand?
	  expand_group_votes.size == (degree * 6)
	end

	def expand_group_votes_count
    expand_group_votes.size
  end

	def users_count
	  @users_count ||= users.count
	end

	def join_group_notifications(new_user)
		users.each do |user|
			self.notifications.create(user: user, poster: new_user, notification_type: self.class.name) unless user == new_user
			# needs testing -- uncomment when email set up
			# GroupMailer.join_group({user: user, group: self, poster: new_user})
		end
	end

	private
	def name_group
		self.name = GroupNameHelper.constellations.sample
	end

	def self.user_friend_group_ids(friend_ids)
		self.includes(:users).references(:users).where("users.id in (?)", friend_ids).ids.uniq
	end

	def find_mergable_group
	  self.class.category_groups(category).degree_groups(degree).where.not(id: id).near([latitude, longitude], 0.5).ready_groups.first
	end

	def aged?(period)
		(Time.now - created_at) > period
	end

	def well_attended_activity_count
		activities.attended_activities.size
	end

	def new_group_user_limit
	  user_limit * 2
	end

	def new_degree
	  degree + 1
	end
end
