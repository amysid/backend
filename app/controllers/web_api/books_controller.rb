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
    render_booth
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

end