class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author_name
      t.string :body
      t.integer :book_duration, default: 0
      t.string :reason_for_rejection
      t.integer :status, default: 0
      t.integer :listen_count, default: 0
      t.datetime :last_listening_at
      
      t.timestamps
    end
  end
end
