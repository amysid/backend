class OperationSerializer < ApplicationSerializer
  attributes :number, :name, :listening_time, :rating, :note
  
  attribute :listening_status, do |opration, _params|
    "#{Time.at(operation.listening_status.to_f).utc.strftime("%H:%M:%S")}" + "/" + "#{Time.at(operation.book.book_duration.to_f).utc.strftime("%H:%M:%S")}"
  end

  attribute :booth_name do |operation, _params|
    operation.booth.name
  end

  attribute :title do |operation, _params|
    operation.book.title
  end

  attribute :city do |operation, _params|
    operation.book.city
  end

end
