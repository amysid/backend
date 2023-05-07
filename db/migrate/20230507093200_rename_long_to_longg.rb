class RenameLongToLongg < ActiveRecord::Migration[6.1]
  def change
    rename_column :books, :long, :longg
  end
end
