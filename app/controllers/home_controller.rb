class HomeController < ApplicationController
	def index
		Game::seed_igdb
		@games = Game.all
		HardWorker.perform_async(5)
	end
end
