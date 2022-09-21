class ApplicationController < ActionController::API

  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameters
  include Rails.application.routes.url_helpers
  include Pagy::Backend


  wrap_parameters false

  def handle_missing_parameters
    head :bad_request
  end


  def not_found
    render json: { error: 'not_found' }
  end

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
end
