class WebApi::BooksController < ::ApplicationController
  before_action :set_booth,  except: [:all_books, :create_operation_for_blind]
  before_action :ensure_booth_present!,  except: [:all_books, :create_operation_for_blind]
  before_action :fetch_categories, only: [:index, :category_search]
  
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

  def search 
    if params[:book].present?
      book_ids = @booth.books.pluck(:book_id)
      @books = Book.includes(:book_files).where(id: book_ids, status: "Published").order('created_at desc')
      @books = @books.includes(:book_files).where("books.title ILIKE ? OR books.author_name ILIKE ?  OR books.body ILIKE ?", "%#{params[:book]}%", "%#{params[:book]}%", "%#{params[:book]}%" ).order('created_at desc')
    end
    if params[:type] == "all"
     @books = @books
    elsif params[:type] == "short"
      @books = @books.where(audio_type: "Short") if @books.present?
    elsif params[:type] == "long"
      @books = @books.where(audio_type: "Long") if @books.present?
    end
    render_books
  end

  def category_search
    if params[:category_id].present?
      book_ids = @booth.books.pluck(:book_id)
      @books = Book.includes(:book_files).where(id: book_ids, status: "Published")
      book_ids = @categories.pluck(:book_id)
      @books = @books.where(id: book_ids)
      @total_books = @books.count || 0
      total_time = @books.pluck(:book_duration).sum
      @total_time = Time.at(total_time).utc.strftime("%Hh %M minute")
      @total_author_count = @books.pluck(:author_name).uniq.count || 0
      
      if params[:type] == "all"
        @books = @books
      elsif params[:type] == "short"
        @books = @books.where(audio_type: "Short")
      elsif params[:type] == "long"
        @books = @books.where(audio_type: "Long")
      end
    end
    render json: {
      multi_data: true,
      books: BookSerializer.new(@books),
      total_books: @total_books,
      total_time: @total_time,
      total_author_count: @total_author_count
    }, status: :ok
  end

  def category_datail
    @category = Category.where(id: params[:category_id]).first
    return render json: {errors: ["Category not present!"]}, status: :forbidden if @category.blank?

    render json: {
      multi_data: true,
      category: CategorySerializer.new(
        @category
      ),
    }, status: :ok 
  end

  def all_books
    @books = Book.includes(:book_files).where(status: "Published").order('created_at desc')
    render json: {
      multi_data: true,
      books: BookSerializer.new(@books),
    }, status: :ok
  end

  def create_operation_for_blind
    book = Book.find_by(id: params[:id])
    booth = Booth.where(name: "Blind").first_or_create
    operation = Operation.create(book_id: book.id, booth_id: booth.id)
    return render json: {operation_number: operation.number}, status: :ok
  end


  def show
    @book = Book.where(id: params[:id]).first
    operation = Operation.create(booth_id: @booth.id, book_id: @book.id)
    
    #path = media_files_web_operation_url(id: operation.number)
    path = "#{ENV["FRONTEND_URL"]}/web/operations/#{operation.number}/media_files"
    if params[:locale].present?
      path = "#{ENV["FRONTEND_URL"]}/#{params[:locale]}/web/operations/#{operation.number}/media_files"
    end
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

  def accessibility_mode
    book_ids = @booth.books.pluck(:book_id)
    @books = Book.includes(:book_files).where(id: book_ids, status: "Published").order('created_at desc')
    render_books
  end

  def children_mode
    @children_category = Category.where(name: "Children’s books").first
    if @children_category.present?
      cat_book_ids = @children_category.books.pluck(:id)
      book_ids = @booth.books.pluck(:book_id) & cat_book_ids
      @books = Book.includes(:book_files).where(id: book_ids, status: "Published").order('created_at desc')
    end
    render_books
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

  def fetch_categories
    @categories = @booth.categories
    if params[:category_id].present?
      @categories = @categories.includes(:books).where(id: params[:category_id])
    end
  end

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

  def render_books
    render json: {
      multi_data: true,
      books: BookSerializer.new(@books)
    }, status: :ok
  end

end