class Api::BooksController < ::ApplicationController
  before_action :authorize_request
  before_action :ensure_category_present?, only: [:create, :update]
  before_action :set_book, except: [:new, :create, :index]
  before_action :ensure_book_present?, except: [:new, :create, :index]
  before_action :update_category_record, only: [:update]

  def index
    if params["book"].present? && params["book"]["search"]
      @books = Book.all.where("books.title LIKE ? OR books.author_name LIKE ?  OR books.body LIKE ?", "%#{params[:book][:search]}%", "%#{params[:book][:search]}%", "%#{params[:book][:search]}%" ).order('created_at desc')
    else
      @books = Book.all.includes(:operations).order('created_at desc')
    end
    @pagination, @books = pagy(
      @books
    )
    render_books
  end
  
  def create
    @book = Book.new(book_params)
    if @book.save
      @book.categories << @categories
      render_book
    else
      render json: { errors: @booth.errors.messages }, status: :forbidden
    end
  end

  def update 
    if @book.update(book_params)
      @book.categories << @new_categories
      render_book
    else
      render json: { errors: @booth.errors.messages }, status: :forbidden
    end
  end

  def show
    render_book
  end

  def edit
  end

  def setting
  end

  def change_status
    status = @book.status == "Published" ? "UnPublished" : "Published"
    @book.update(status: status)
    render_book
  end

  def destroy
    if @book.destroy
      render json: { message: ["Book Destroy Successfully!"], status_code: 200 }, status: :ok
    else
    render json: { errors: @book.errors.messages }, status: :forbidden
    end
  end

  private

  # def book_params
  #   params.require(:book).permit(:title, :language, :arabic_author_name, :arabic_title, :arabic_body, :author_name, :book_duration, :body,
  #     :user_id, :audio_type, book_files_attributes: [:id, :book_cover_file, :audio, :short_audio_file, :_destroy]
  #   )
  # end

  def book_params
    params.require(:book).permit(:title, :language, :arabic_author_name, :arabic_title, :arabic_body, :author_name, :book_duration, :body,
      :user_id, :audio_type, :book_cover_file, :audio, :short_audio_file, :cover, :short, :long
    )
  end

  def set_book
    @book = Book.find_by(id: params[:id])
  end

  def ensure_book_present?
    if @book.blank?
      return render json: { errors: ["Book not present or User not authorized"] }, status: :forbidden
    end
  end

  def ensure_category_present?
    @categories = Category.where(id: params[:book][:category_ids])
    if @categories.blank?
      return render json: { errors: ["Data not present or User not authorized"] }, status: :forbidden
    end
  end

  def update_category_record
    existing_category_id = @book.category_ids
    category_ids_for_remove = existing_category_id - @categories.pluck(:id)
    @book.category_ids -= category_ids_for_remove
    @new_categories = @categories.where.not(id: existing_category_id)
  end

  def render_books
    render json: {
      multi_data: true,
      books: BookSerializer.new(
        @books,
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

  def render_book
    render json: {
      multi_data: true,
      book: BookSerializer.new(
        @book
      ),
    }, status: :ok 
  end
end