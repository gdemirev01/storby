
class Game < ApplicationRecord
	has_many :reviews
	validates_presence_of :name, :price
	has_many_attached :source
	has_many_attached :images
	has_and_belongs_to_many :users

	enum genre: { action: 0, adventure: 1, rpg: 2, strategy: 3, sports: 4}

	include Recommendation

	def self.seed_igdb
		require 'rest-client'
		require 'rails/configuration'
		#New York Times API endpoint
		igdb_url = "https://api-v3.igdb.com/games/?fields=*&limit=10"
		#RestClient get request to the NYT endpoint with my API Key being parsed into a JS object
		data = JSON.parse( RestClient.get("#{igdb_url}", headers = {"user-key" => "4b4c9d5be0d86c10d9d3c239c7b67215"}) )
		data.each do |game|
			existing_game = Game.find_by(name: game["name"])
			if(!existing_game)
			    game = Game.new do |g|
			    	g.id = game["id"]
			    	g.name = game["name"] 
			    	g.desc = game["summary"]
			    	g.price = 0
			    	g.created_at = game["created_at"]
			    	g.updated_at = game["created_at"]
			    	g.status = "released"
			    	g.relese_date = game["first_release_date"]
			    	g.imageCounter = 0
			    	g.genre = 0

			    	

			    	if !game["screenshots"].nil?
			    		screenshot_id = game["screenshots"][0]
			    		image_url = "https://api-v3.igdb.com/screenshots/#{screenshot_id}?fields=url"

						images = JSON.parse( RestClient.get("#{image_url}", headers = {"user-key" => "4b4c9d5be0d86c10d9d3c239c7b67215"}) )
						p "IMAGEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
						p images
						g.igdb_image_url = images[0]["url"]
			    	else 
			    		p "NO IMAGE FOUND"
			    	end
			    end

			    if game.save
			      puts "saved game"
			    else
			      puts "not saved"
			    end
			end
		end
	end

end
