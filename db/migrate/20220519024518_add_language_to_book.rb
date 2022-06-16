class AddLanguageToBook < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :language, :integer, default:0
  end
end
