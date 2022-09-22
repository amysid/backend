class WebApi::BoothsController < ::ApplicationController
  before_action :set_booth, only: [:show, :booth_cover_urls, :categories]
  before_action :ensure_booth_present!, only: [:show, :booth_cover_urls, :categories] 
  
  def index
    per_page = params[:per_page] || 10
    @booths = Booth.all.order('created_at desc')
    render_booths
  end


  def show
    render_booth
  end

  def booth_cover_urls
    @books = @booth.books.limit(8).shuffle
    data = {}
    data["book_cover_urls"] = []
    if @books.present?
      book_cover_urls = @books.map do |book|
        # book.book_files.first.book_cover_file.url rescue nil
        ENV["BACKEND_URL"] + rails_blob_path(book.book_cover_file , only_path: true) if book.book_cover_file.present?
      end
      data["book_cover_urls"] = book_cover_urls
    end
    render json: {data: data}, status: :ok
  end

  def categories
    @categories = @booth.categories
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
  
  private

  def set_booth
    @booth = Booth.where(number: params[:id]).first
  end

  def ensure_booth_present!
    return true if @booth.present?

    return render json: { errors: ["Data not present or booth not authorized"] }, status: :forbidden
  end
  
  def fetch_categories
    @categories = @booth.categories
    if params[:category_id].present?
      @categories = @categories.includes(:books).where(id: params[:category_id])
    end
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
