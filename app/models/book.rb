class Book < ApplicationRecord
  has_many :book_files,dependent: :destroy
  has_many :operations, dependent: :destroy
  has_and_belongs_to_many :categories, dependent: :destroy
  accepts_nested_attributes_for :book_files 
  enum status: ["UnPublished", "Published"]
  enum audio_type: ["Short", "Long"] 
  enum language: ["English", "Arabic"] 
end
