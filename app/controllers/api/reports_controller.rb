class Api::ReportsController < ::ApplicationController

  def index
    if params[:report].present?
      if params[:report][:category_id] == "All"
        categories = Category.all
        booth_ids = categories.map{|category| category.booths.map(&:id)}.flatten.compact.uniq
        @booths = Booth.where(id: booth_ids)
      else
        category = Category.find_by(id: params[:report][:category_id])
        @booths = category.blank? ? nil : category.booths 
      end

      if params[:report][:booth_id].present? && params[:report][:booth_id] != "All"
        if @booths.present? 
          @booths = @booths.where(id: params[:report][:booth_id])
        else
          @booths = Booth.where(id: params[:report][:booth_id])
        end
      end
      if params[:report][:language] == "All"
        @books = Book.all
      else
        @books = Book.where(language: params[:report][:language])
      end
      if params[:report][:duration].present? && params[:report][:duration] != "All"
        if @books.present?
          @books = @books.where(audio_type: params[:report][:duration])
        else
          @books = Book.where(audio_type: params[:report][:duration])
        end
      end

      if params[:report][:book_id].present? && params[:report][:book_id] != "All"
        if @books.present?
          @books = @books.where(id: params[:report][:book_id])
        else
          @books = Book.where(id: params[:report][:book_id])
        end
      end

      if params[:report][:start_date].present? && params[:report][:end_date].present?
        @operations = Operation.where(book_id: @books.to_a.map(&:id)).and(Operation.where(booth_id: @booths.to_a.map(&:id))).where(created_at: params[:report][:start_date]..params[:report][:end_date])
      else
        @operations = Operation.where(book_id: @books.to_a.map(&:id)).and(Operation.where(booth_id: @booths.to_a.map(&:id)))
      end
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
    operation_group_by_hour = nil
    opreation_group_by_day = nil
    if @operations.present?
      operation_group_by_hour = @operations.group_by_hour(:created_at).count
      opreation_group_by_day = @operations.group_by_day_of_week(:created_at, format: "%a").count
    end
    total_comments = @operations.to_a.select{|x| x.note.present?}.count
    opration_having_rate = @operations.to_a.select{|x| x.rating.present? }
    avarage_rate = opration_having_rate.present? ?  opration_having_rate.map(&:rating).map(&:to_i).sum / opration_having_rate.count : 0
    total_listening_number = @operations.to_a.select{|x| x.listening_time.present?}.count
    total_listening_time = @operations.to_a.map(&:listening_status).map(&:to_i).sum
    total_listening_time = Time.at(total_listening_time).utc.strftime("%H:%M:%S")

    data = {booth_details:  @booth_details, operations: @operations, booths: booths,
            operation_group_by_hour: operation_group_by_hour, opreation_group_by_day: opreation_group_by_day,
            total_comments: total_comments, avarage_rate: avarage_rate, total_listening_number: total_listening_number,
            total_listening_time: total_listening_time }
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