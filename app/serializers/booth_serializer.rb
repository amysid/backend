class BoothSerializer  < ApplicationSerializer
  attributes :id,  :number, :name, :city, :address, :communicate_with, :latitude, :longitude, :location,
             :phone_number, :status, :listening_count

  attribute :last_listening do |booth, _params|
    booth.operations.last.created_at if booth.operations.present?
  end

  attribute :listening_count_for do |booth, _params|
    booth.operations.select{|x| x.listening_status != nil}.count
  end

  attribute :selected_category_id do |booth, _params|
    booth.categories.pluck(:id) if booth.categories.present?
  end

end