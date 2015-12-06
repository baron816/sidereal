class BetaCodesController < ApplicationController
  def new
    @beta_code = BetaCode.new
  end

  def create
    @beta_code = BetaCode.new(beta_params)

    if @beta_code.save
      UserMailer.delay.beta_code(@beta_code)

      redirect_to root_path, notice: "Thanks for signing up for the beta. We'll email you if we can fit you in."
    else
      render :new
    end
  end

  private
  def beta_params
    params.require(:beta_code).permit(:email)
  end
end