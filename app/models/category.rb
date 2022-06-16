class Category < ApplicationRecord
  has_and_belongs_to_many :books, dependent: :destroy
  has_and_belongs_to_many :booths, dependent: :destroy
  has_one_attached :icon, dependent: :destroy
  has_one_attached :white_icon, dependent: :destroy

  enum status: ["Active","Inactive"]
end
