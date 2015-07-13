class DropUserVotesController < ApplicationController
	before_action :set_group
	before_action :user_logged?, only: [:create]

	def create
		@user = User.find(params[:user_id])
		@vote = @group.drop_user_votes.new(user: @user, voter: current_user)
		@vote.save
		@group.kick_user(@user)
		respond_to do |format|
			format.html { redirect_to @group }
			format.js
		end
	end

	def destroy
		@vote = DropUserVote.find(params[:id])
		@user = @vote.user
		@vote.destroy
		respond_to do |format|
			format.html { redirect_to @group }
			format.js
		end
	end

	private
	def set_group
		@group = Group.find(params[:group_id])
	end
end
