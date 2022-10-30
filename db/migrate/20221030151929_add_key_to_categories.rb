class AddKeyToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :logo, :string
    add_column :categories, :white_logo, :string
  end
end
