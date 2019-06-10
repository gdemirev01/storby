class AddIgdbImageUrlToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :igdb_image_url, :string
  end
end
