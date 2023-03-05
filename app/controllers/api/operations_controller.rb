class Api::OperationsController < ::ApplicationController
  before_action :authorize_request
  
  def index
    if params[:operation].present? && params[:operation][:search].present?
      if params[:operation][:search] == "Only Comment"
        @operations = Operation.all.includes(:book, :booth).where(rating: [nil, ""]).where.not(note: [nil, ""]).order('created_at desc')
      elsif params[:operation][:search] == "Only Rate"
        @operations = Operation.all.includes(:book, :booth).where(note: [nil, ""]).where.not(rating: [nil, ""]).order('created_at desc')
      elsif params[:operation][:search] == "Rate With Comment"
        # @operations =Operation.all.includes(:book, :booth).where.not(note: nil, rating: nil).order('created_at desc')
        @operations =Operation.all.includes(:book, :booth).where.not(note: [nil, ""]).where.not(rating: [nil, ""]).order('created_at desc')
      end 
    else
      @operations = Operation.all.includes(:book, :booth).order('created_at desc')
    end
    @pagination, @operations = pagy(
      @operations,
      items: params[:page_size] || 10,
      page: params[:page] || 1
    )
    render_operations
  end
  
  def render_operations
    render json: {
      multi_data: true,
      operations: OperationSerializer.new(
        @operations,
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
end