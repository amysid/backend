class WebApi::BooksController < ::ApplicationController
  before_action :set_booth
  before_action :ensure_booth_present!
  # before_action :fetch_categories, only: [:index]
  
  def index
    book_ids = @booth.books.pluck(:book_id)
    @books = Book.includes(:book_files).where(id: book_ids, status: "Published").order('created_at desc')
    
    book_ids_from_operation = Operation.where(booth_id: @booth.id).pluck(:book_id)
    @trending_books = @books.where(id: book_ids_from_operation)
    @trending_books = @books if @trending_books.blank?
    
    render json: {
      multi_data: true,
      books: BookSerializer.new(@books),
      trending_books: BookSerializer.new(@trending_books),
    }, status: :ok
  end


  def show
    @book = Book.where(id: params[:id]).first
    operation = Operation.create(booth_id: @booth.id, book_id: @book.id)
    
    #path = media_files_web_operation_url(id: operation.number)
    path = "#{ENV["FRONTEND_URL"]}/#{params[:locale]}/web/operations/#{operation.number}/media_files"
    @qr_code = RQRCode::QRCode.new(path)
    @qr_png = @qr_code.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 10,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 140
    )
    render_book
  end

  def booth_cover_urls
    @books = @booth.books.limit(8).shuffle
    data = {}
    data["book_cover_urls"] = []
    if @books.present?
      book_cover_urls = @books.map do |book|
        book.book_files.first.book_cover_file.url rescue nil
      end
      data["book_cover_urls"] = book_cover_urls
    end
    render json: {data: data}, status: :ok
  end
  
  private

  def set_booth
    @booth = Booth.where(number: params[:booth_id]).first
  end

  def ensure_booth_present!
    return true if @booth.present?

    return render json: { errors: ["Data not present or booth not authorized"] }, status: :forbidden
  end

  def render_book
    render json: {
      multi_data: true,
      book: BookSerializer.new(
        @book,
      ),
      qr_png_link:"data:image/png;base64,#{Base64.encode64(@qr_png.to_s).gsub("\n", "")}"
    }, status: :ok 
  end

end