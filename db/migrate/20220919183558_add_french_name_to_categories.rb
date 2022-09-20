class AddFrenchNameToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :french_name, :string
  end
end
