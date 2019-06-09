# LPT: Rails doesn't automatically reload files required with require '' 
# I wish I'd known this 40 minutes ago

module Recommendation
    def recommend_games

        if self.games.size > 0
            #try to make this only get users who have left at least one review
            other_users = self.class.all.where.not(id: self.id)
            recommended = Hash.new(0)

            other_users.each do |user|
                common_games = self.games & user.games
                weight = common_games.size.to_f / user.games.size.to_f

                #Here rests in peace an hour of wasted time due to the piece of shit that is the em dash
                #Go ahead, look it up
                #But don't ever use it 
                #DO NOT EVER USE IT

                (user.games - common_games).each do |game|
                    recommended[game] += weight
                end
            end

            unless recommended.empty? then return recommended.sort_by { |key, value| value }.reverse.map { |key, value| key }.first(4) end    
        end
        recommended = Game.all.take(4)
    end

    def recommend_similar_games
        same_genre_games = self.class.all.where(genre: self.genre)

        #exclude current game
        same_genre_games -= [self]

        recommended = Hash.new(0)

        same_genre_games.each do |game|
            shared_users = self.users & game.users
            recommended[game] = shared_users.size
        end

        unless recommended.empty? then return recommended.sort_by { |key, value| value }.reverse.map { |key, value| key }.first(4) end

        return Game.all.take(4)
    end
end