class HomeController < ApplicationController
	def index
		Game::seed_igdb
		@games = Game.all
	end
end
