class HomeController < ApplicationController
	def index
		@games = Game.all
		HardWorker.perform_async(5)
	end
end
