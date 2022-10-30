class AddUrlToBooksAndCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :book_cover_file_url, :string
    add_column :books, :audio_url, :string
    add_column :books, :short_audio_file_url, :string
    add_column :categories, :icon_url, :string
    add_column :categories, :white_icon_url, :string
  end
end
