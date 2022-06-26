class Api::HomesController < ::ApplicationController
  before_action :authorize_request
  
  def index
    @operations = Operation.includes(:book, booth: :categories).references(:book, booth: :categories)
    @operations_with_listening_status = @operations.where.not(listening_status: nil)
    @books = Book.all
    @booths = Booth.all
    @category_group = @operations_with_listening_status.group("categories.name").count
    @booth_details = @operations.group("booths.name").count
    @last_10_day_listing = @operations.where("operations.created_at > '#{(Time.now - 10.days)}'")
    @book_details = @operations.group("books.title").count
    @book_details =  Hash[@book_details.sort_by{|k, v| v}.reverse].first(5).to_h
    @rating_wise_group = @operations.group(:rating).count
    @book_language_detail = @operations.group(:language).count
    @book_listening_type  = @operations.group("books.audio_type").count.map { |k, v| [Book.audio_types.key(k), v] }.to_h
    data = {}
    data["operations_count"] =  @operations.count
    data["books_count"] = @books.count
    data["booths_count"] = @booths.count
    data["category_group"] = @category_group
    data["booth_details"] = @booth_details
    data["last_10_day_listing"] = @last_10_day_listing.group_by_day(:created_at).count
    data["rating_wise_group"] = @rating_wise_group
    data["book_details"] = @book_details
    data["book_listening_type"] = @book_listening_type
    data["category_group"] =   @category_group
    data["book_language_detail"] = @book_language_detail
    render json: {data: data}, status: :ok
  end

end