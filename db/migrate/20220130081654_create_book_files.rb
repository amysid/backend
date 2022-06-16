class CreateBookFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :book_files do |t|
      # t.string :book_cover
      # t.string :audio_file
      # t.string :short_audio
      t.references :book 

      
      t.timestamps
    end
  end
end
