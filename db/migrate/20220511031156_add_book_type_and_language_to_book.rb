class AddBookTypeAndLanguageToBook < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :audio_type, :integer, default: 0
    add_column :operations, :language, :integer, default: 0
  end
end
