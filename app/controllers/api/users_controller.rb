class Api::UsersController < ::ApplicationController
  before_action :authorize_request
  before_action :set_user, except: [:index, :create]
  before_action :ensure_user_present!, except: [:index, :create]
  
  def index
    per_page = params[:per_page] || 10
    @users = User.all.order('created_at desc').paginate(page: params[:page], per_page: per_page)
    render_users
  end

  def create
    @user = User.new(user_params)
    @user.password = rand(10000..90000).to_s
    if @user.save
      render_user
    else
      render json: { errors: @user.errors.messages }, status: :forbidden
    end
  end

  def show
    render_user
  end

  def destroy
    if @user.destroy
      render json: { message: ["User Destroy Successfully!"] }, status: :ok
    else
      render json: { errors: @user.errors.messages }, status: :forbidden
    end
  end

  def update
    @user.update(user_params)
    render_user
  end
  
  private

  def user_params
    params.require(:user).permit(:full_name, :mobile, :email, :gender, :role)
  end

  def set_user
    @user = User.where(id: params[:id]).first
  end

  def ensure_user_present!
    return true if @user.present?

    return render json: { errors: ["Data not present or user not authorized"] }, status: :forbidden
  end

  def render_user
    render json: {
      multi_data: true,
      user: UserSerializer.new(
        @user
      ),
    }, status: :ok 
  end
  
  def render_users
    render json: {
      multi_data: true,
      users: UserSerializer.new(
        @users,
        {
          meta: {
          },
        }
      ),
    }, status: :ok 
  end
end