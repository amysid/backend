class Booth < ApplicationRecord
  has_secure_token :number
  has_and_belongs_to_many :categories, dependent: :destroy
  has_and_belongs_to_many :users, options: true
  has_many :operations, dependent: :destroy
  has_many :books, through: :categories
  
  enum status: ["Active","Inactive"]

  def coordinate
    return "#{self.latitude},#{self.longitude}"
  end
end
