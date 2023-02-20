class Api::ReportsController < ::ApplicationController

  def index
    if params[:report].present?
      if params[:report][:category_id]
        category = Category.find_by(id: params[:report][:category_id])
        @booths = category.blank? ? nil : category.booths 
      end
      if params[:report][:booth_id].present?
        if @booths.present?
          @booths = @booths.where(id: params[:report][:booth_id])
        else
          @booths = Booth.where(id: params[:report][:booth_id])
        end
      end
      if params[:report][:language].present?
        @books = Book.where(language: params[:report][:language])
      end
      if params[:report][:duration].present?
        if @books.present?
          @books = @books.where(audio_type: params[:report][:duration])
        else
          @books = Book.where(audio_type: params[:report][:duration])
        end
      end

      @operations = Operation.where(book_id: @books.to_a.map(&:id)).or(Operation.where(booth_id: @booths.to_a.map(&:id)))
      @operations = @operations.includes(:book, booth: :categories).references(:book, booth: :categories) if @operations.present?

      if @operations.present? && @booths.blank?
        @booths = Booth.all.includes(:books).where(id: @operations.map(&:id))
      end
      @booth_details = @operations.group("booths.name").count if @operations.present?
    else
      @operations = Operation.includes(:book, booth: :categories).references(:book, booth: :categories)
      @booths = Booth.all.includes(:books)
      @booth_details = @operations.group("booths.name").count if @operations.present?
    end
    
    if @booths.present?
      booths = @booths.map do |booth|
        book_detail = book_detail_for(booth)
        day_wise_info = day_wise_info_for(booth, @operations)
        listening_count = listening_count_for(booth)
        booth.as_json.merge!(book_detail: book_detail, day_wise_info: day_wise_info, listening_count: listening_count)
      end
    end
    data = {booth_details:  @booth_details, operations: @operations, booths: booths }
    return render json: {data: data}, status: :ok
  end

  def book_detail_for(booth)
    books = booth.books
    h = {}
    book_count_language_wise = books.group(:language).count
    h.merge!(book_count_language_wise)
    book_count_type_wise = books.group("books.audio_type").count
    h.merge!(book_count_type_wise)
    return h
  end

  def day_wise_info_for(booth, operations)
    booth_ops = operations.where(booth_id: booth.id)
    return booth_ops.group_by_day_of_week(:created_at, format: "%a").count rescue {}
  end

  def listening_count_for(booth)
    return booth.operations.select{|x| x.listening_status != nil}.count
  end

end