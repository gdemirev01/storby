class AddIndexToGames < ActiveRecord::Migration[5.2]
  def change
    add_index :games, :genre
  end
end
