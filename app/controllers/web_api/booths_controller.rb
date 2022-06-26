class WebApi::BoothsController < ::ApplicationController
  before_action :set_booth, only: [:show, :booth_cover_urls]
  before_action :ensure_booth_present!, only: [:show, :booth_cover_urls] 
  
  def index
    per_page = params[:per_page] || 10
    @booths = Booth.all.order('created_at desc').paginate(page: params[:page], per_page: per_page)
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
        book.book_files.first.book_cover_file.url resuce nil
      end
      data["book_cover_urls"] = book_cover_urls
    end
    render json: {data: data}, status: :ok
  end
  
  private

  def set_booth
    @booth = Booth.where(number: params[:id]).first
  end

  def ensure_booth_present!
    return true if @booth.present?

    return render json: { errors: ["Data not present or booth not authorized"] }, status: :forbidden
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