class Operation < ApplicationRecord
  has_secure_token :number
  
  belongs_to :booth
  belongs_to :book
  has_many :categories, through: :booth
  enum language: ["English", "Arabic"]

  validates :note, format: { with: /\A[a-zA-Z0-9.@#!|]+\z/, message: "Input Invalid Special Charecter not Allow!" }

end
