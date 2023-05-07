class Api::CategoriesController < ::ApplicationController
  before_action :authorize_request
  before_action :set_category, except: [:index, :create]
  before_action :ensure_category_present!, except: [:index, :create]
  
  def index
    @categories = Category.all.order('created_at desc')
    @pagination, @categories = pagy(
      @categories,
      items: params[:page_size] || 10,
      page: params[:page] || 1
    )
    render_categories
  end

  def create
    @category = Category.new({
      name: params[:category][:name],
      logo: params[:category][:dark],
      white_logo: params[:category][:white],
      arabic_name: params[:category][:arabic_name],
      french_name: params[:category][:french_name],
      icon: params[:category][:icon],
      white_icon: params[:category][:white_icon]
      })
    if @category.save
      render_category
    else
      render json: { errors: @category.errors.messages }, status: :forbidden
    end
  end

  def show
    render_category
  end
#working
  def destroy
    if @category.destroy
      render json: { message: ["Category Destroy Successfully!"], status_code: 200 }, status: :ok
    else
      render json: { errors: @category.errors.messages }, status: :forbidden
    end
  end

  def update
    @category.update({
      name: params[:category][:name],
      arabic_name: params[:category][:arabic_name],
      french_name: params[:category][:french_name],
      icon: params[:category][:icon],
      white_icon: params[:category][:white_icon]
    })
    
    @category.logo = params[:category][:dark] if params[:category][:dark].present?
    @category.white_logo =  params[:category][:white] if params[:category][:white].present?
    @category.save
    render_category
  end
  
  private

  def category_params
    params.require(:category).permit(:name, :arabic_name, :french_name, :logo, :white_logo, :icon, :white_icon)
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
            total: @pagination.count,
            page: @pagination.page,
            page_size: @pagination.items,
            total_pages: @pagination.pages
          },
        }
      ),
    }, status: :ok 
  end
end