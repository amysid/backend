class Api::OperationsController < ::ApplicationController
  before_action :authorize_request
  
  def index
    per_page = params[:per_page] || 10
    @operations = Operation.all.includes(:book, :booth).order('created_at desc').paginate(page: params[:page], per_page: per_page)
  end
  
  def render_operations
    render json: {
      multi_data: true,
      operations: OperationSerializer.new(
        @operations,
        {
          meta: {
          },
        }
      ),
    }, status: :ok 
  end
end