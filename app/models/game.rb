
class Game < ApplicationRecord
	has_many :orders
	has_many :reviews
	validates_presence_of :name, :price, :source
	has_many_attached :source
	has_many_attached :images
	has_and_belongs_to_many :users

	enum genre: { action: 0, adventure: 1, rpg: 2, strategy: 3, sports: 4}
end
