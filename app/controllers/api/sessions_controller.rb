class Api::SessionsController < ::ApplicationController
  before_action :ensure_valid_user?, only: :create
  
  def create
    token = JsonWebToken.encode({user_id: @user.id })
    render_token(token)
  end

  def ensure_valid_user?
    @user = User.where(email: params[:email]).first
    return true if @user.present? && @user.authenticate(params[:password])

    return render json: { errors: ["Email or Password is invalid"] }, status: :forbidden
  end

  def render_token(token)
    render json: {
      token: token,
      id: @user.id,
      name: @user.full_name,
      email: @user.email
    }
  end

end