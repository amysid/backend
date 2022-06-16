class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :full_name, default: ""
      t.string :mobile, default: ""
      t.string :email, default: ""
      t.integer :gender, default: 0
      t.integer :role
      t.integer :status , default: 0
      t.string :password_digest, default: ""
      t.string :verificatin_link, default: ""
      t.datetime :last_login_at
      t.timestamps
    end
  end
end
