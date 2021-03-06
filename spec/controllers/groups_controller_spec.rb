require 'rails_helper'

describe GroupsController do
  let!(:user) { create(:user_home) }
  let!(:group) { Group.first }
  before do
    log_in(user)
  end

  describe "GET #show" do
  	before do
  	  get :show, id: group
  	end

    it "renders show template" do
    	expect(response).to render_template(:show)
    end

    it "finds the correct group" do
    	expect(assigns[:group_show].group).to eq(group)
    end

    it "has a new topic" do
    	expect(assigns[:group_show].new_topic).to be_a_new(Topic)
    end
  end

  describe "DELETE #drop_user" do
  	it "finds the correct group" do
  		delete :drop_user, id: group
  		expect(assigns[:group]).to eq(group)
  	end

    it "drops the user's group" do
    	expect { delete :drop_user, id: group }.to change(user.groups, :count).by(-1)
    end
  end
end
