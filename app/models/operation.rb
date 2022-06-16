class Operation < ApplicationRecord
  has_secure_token :number
  
  belongs_to :booth
  belongs_to :book
  has_many :categories, through: :booth
  enum language: ["English", "Arabic"] 

end
