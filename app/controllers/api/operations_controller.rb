class Api::OperationsController < ::ApplicationController
  before_action :authorize_request
  
  def index
    @operations = Operation.all.includes(:book, :booth).order('created_at desc')
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