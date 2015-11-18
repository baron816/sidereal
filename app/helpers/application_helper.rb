module ApplicationHelper
	def categories
		[
			"Professional",
			"Creative",
			"Working Class",
			"Doesn't Matter"
		]
	end

	def age_groups
	  [
			"Select Age Group",
			"18-24",
			"22-28",
			"27-33",
			"32-42",
			"38-55",
			"52-67",
			"65+",
			"Doesn't Matter"
		]
	end

	def gender_groups
	  [
			"Women Only",
			"Men Only",
			"Doesn't Matter"
		]
	end

	def reasons_for_leaving
	  [
			"Didn't form connection with others in group",
			"Interface was too confusing",
			"Too busy to meet people",
			"Too many email notifications"
		]
	end

	def self.mean(*args)
	  args.inject(:+) / args.length.to_f
	end
end
