class BookFile < ApplicationRecord
  belongs_to :book
  has_one_attached :book_cover_file, dependent: :destroy
  has_one_attached :audio, dependent: :destroy
  has_one_attached :short_audio_file, dependent: :destroy

end
