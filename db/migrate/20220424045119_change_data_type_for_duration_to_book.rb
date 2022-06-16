class ChangeDataTypeForDurationToBook < ActiveRecord::Migration[6.1]
  def up
    change_column :books, :book_duration, :decimal
    change_column :operations, :listening_status, :decimal, using: "listening_status::numeric"
  end

  def down
    change_column :books, :book_duration, :integer
    change_column :operations, :listening_status, :string
  end
end
