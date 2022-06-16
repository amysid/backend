class AddArabicDetailToBook < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :arabic_author_name, :string
    add_column :books, :arabic_title, :string
    add_column :books, :arabic_body, :string
  end
end
