class CreateJoinTableBoothsCategories < ActiveRecord::Migration[6.1]
  def change
    create_join_table :booths, :categories do |t|
      t.index [:booth_id, :category_id]
      t.index [:category_id, :booth_id]
    end
  end
end
