class CreateSimilarities < ActiveRecord::Migration[5.2]
  def change
    create_table :similarities do |t|
      t.integer :user_a_id, null: :false
      t.integer :user_b_id, null: :false
      t.float :score

      t.timestamps
    end
  end
end
