class WebApi::OperationsController < ::ApplicationController
  before_action :set_operation
  before_action :ensure_operation_present?

  def media_files
    @book = @operation.book
    language = params[:locale] == "en" ? "English" : "Arabic"
    @operation.update(language: language)
    @book.update(last_listening_at: Time.now)
    render json: {
      multi_data: true,
      operation: OperationSerializer.new( @operation ),
      book: BookSerializer.new( @book ),
    }, status: :ok 
  end

  def update_listen_count
    current_listen_time = params[:current_time].to_f
    total_time = params[:file_duration].to_f
    listen_time = current_listen_time.to_f
    @operation.update(listening_time: Time.now, listening_status: listen_time)
    render json: {message: "successfully save count"}
  end

  def save_feedback
    @operation.update(rating: params[:feedback][:rating], note: params[:feedback][:note])
    render json: {message: "data save successfully"}
  end

  private

  def set_operation
    @operation = Operation.find_by(number: params[:id])
  end

  def ensure_operation_present?
    return true if @operation.present?

    render json: {errors: ["Operation Not present!"]}
  end

end
