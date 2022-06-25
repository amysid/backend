class Api::BoothsController < ::ApplicationController
  before_action :authorize_request
  before_action :ensure_user_and_category_present, only: [:create, :update]
  before_action :set_booth, except: [:index, :create]
  before_action :ensure_booth_present!, except: [:index, :create]
  before_action :update_category_record, only: [:update]
  
  def index
    per_page = params[:per_page] || 10
    @booths = Booth.all.order('created_at desc').paginate(page: params[:page], per_page: per_page)
    render_booths
  end

  def create
    @booth = Booth.new(booth_params)
    if @booth.save
      @booth.categories << @categories
      render_booth
    else
      render json: { errors: @booth.errors.messages }, status: :forbidden
    end
  end

  def show
    render_booth
  end

  def destroy
    if @booth.destroy
      render json: { message: ["booth Destroy Successfully!"] }, status: :ok
    else
      render json: { errors: @booth.errors.messages }, status: :forbidden
    end
  end

  def update
    @booth.update(booth_params)
    @booth.categories << @new_categories
    render_booth
  end
  
  private

  def booth_params
    coordinate = params[:booth][:coordinate]
    latitude = coordinate.split(",").first
    longitude = coordinate.split(",").second
    params[:booth].merge!({latitude: latitude, longitude: longitude})
    params.require(:booth).permit(:name, :city, :address, :phone_number, :latitude, :longitude, :communicate_with)
  end

  def set_booth
    @booth = Booth.where(id: params[:id]).first
  end

  def ensure_booth_present!
    return true if @booth.present?

    return render json: { errors: ["Data not present or booth not authorized"] }, status: :forbidden
  end

  def ensure_user_and_category_present
    @user = User.find_by(id:params[:booth][:user_id])
    @categories = Category.where(id: params[:booth][:category_id])
    if @categories.blank?
      return render json: { errors: ["Data not present or booth not authorized"] }, status: :forbidden
    end
  end

  def update_category_record
    existing_category_id = @booth.category_ids
    category_ids_for_remove = existing_category_id - @categories.pluck(:id)
    @booth.category_ids -= category_ids_for_remove
    @new_categories = @categories.where.not(id: existing_category_id)
  end

  def render_booth
    render json: {
      multi_data: true,
      booth: BoothSerializer.new(
        @booth
      ),
    }, status: :ok 
  end
  
  def render_booths
    render json: {
      multi_data: true,
      booths: BoothSerializer.new(
        @booths,
        {
          meta: {
          },
        }
      ),
    }, status: :ok 
  end
end