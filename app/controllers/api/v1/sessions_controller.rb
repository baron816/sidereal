class Api::V1::SessionsController < ApiController
  def create
    user_password = params[:session][:password]
    user_email = params[:session][:email]
    user = User.find_by(email: user_email.downcase).try(:authenticate, user_password)

    if user
      user.generate_token(:auth_token)
      user.save
      render json: user, status: 200
    else
      render json: { errors: "Invalid email or password" }, status: 422
    end
  end

  def destroy
    user = User.find_by(auth_token: params[:id])
    user.generate_token(:auth_token)
    user.save
    head 204
  end
end
