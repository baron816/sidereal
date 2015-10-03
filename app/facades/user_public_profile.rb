class UserPublicProfile
  def initialize(user, current_user)
    @user = user
    @current_user = current_user
  end

  delegate :name, :email, :category, :id, to: :user, prefix: true
  delegate :any?, to: :personal_messages, prefix: true

  def user_location
    user.address.split(',')[1..-1].join(',')
  end

  def personal_messages
    @messages ||= Message.personal_messages(user, current_user)
  end

  def new_message
    Message.new(messageable_id: user.id, poster_id: current_user, messageable_type: user.class)
  end

  def own_profile?
    @user == current_user
  end

  private
  attr_reader :user, :current_user
end
