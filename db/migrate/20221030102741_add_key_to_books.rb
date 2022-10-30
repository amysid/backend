class AddKeyToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :cover, :string
    add_column :books, :short, :string
    add_column :books, :long, :string
  end
end
