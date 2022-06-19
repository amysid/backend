class BoothSerializer  < ApplicationSerializer
  attributes :id,  :number, :name, :city, :address, :communicate_with, :latitude, :longitude, :location,
             :phone_number, :status, :listening_count
end