class Api::CategoriesController < ::ApplicationController
  before_action :authorize_request
  before_action :set_category, except: [:index, :create]
  before_action :ensure_category_present!, except: [:index, :create]
  
  def index
    per_page = params[:per_page] || 10
    @categories = Category.all.order('created_at desc').paginate(page: params[:page], per_page: per_page)
    render_categories
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      render_category
    else
      render json: { errors: @category.errors.messages }, status: :forbidden
    end
  end

  def show
    render_category
  end

  def destroy
    if @category.destroy
      render json: { message: ["User Destroy Successfully!"] }, status: :ok
    else
      render json: { errors: @category.errors.messages }, status: :forbidden
    end
  end

  def update
    @category.update(category_params)
    render_category
  end
  
  private

  def category_params
    params.require(:category).permit(:name, :arabic_name, :icon, :white_icon)
  end

  def set_category
    @category = Category.where(id: params[:id]).first
  end

  def ensure_category_present!
    return true if @category.present?

    return render json: { errors: ["Data not present or user not authorized"] }, status: :forbidden
  end

  def render_category
    render json: {
      multi_data: true,
      category: CategorySerializer.new(
        @category
      ),
    }, status: :ok 
  end
  
  def render_categories
    render json: {
      multi_data: true,
      categories: CategorySerializer.new(
        @categories,
        {
          meta: {
          },
        }
      ),
    }, status: :ok 
  end
end