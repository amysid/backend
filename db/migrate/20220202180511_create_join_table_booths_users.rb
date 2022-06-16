class CreateJoinTableBoothsUsers < ActiveRecord::Migration[6.1]
  def change
    create_join_table :booths, :users do |t|
      t.index [:booth_id, :user_id]
      t.index [:user_id, :booth_id]
    end
  end
end
