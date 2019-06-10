# LPT: Rails doesn't automatically reload files required with require '' 
# I wish I'd known this 40 minutes ago

module Recommendation
    def recommend_games
        if self.games.size > 0
            # set_similar_users(5)

            #try to make this only get users who have left at least one review
            other_users = self.class.all.where.not(id: self.id)
            recommended = Hash.new(0)

            self.similarities.each do |similarity|
                common_games = self.games & similarity.user_b.games

                (similarity.user_b.games - common_games).each do |game|
                    recommended[game] += similarity.score
                end
            end

            unless recommended.empty? then return recommended.sort_by { |key, value| value }.reverse.map { |key, value| key }.first(4) end    
        end
        recommended = Game.all.take(4)
    end

    def find_similar_users_jaccard(max_users)
        similarity = Hash.new(0)
        if self.games.size > 0
            other_users = self.class.all.where.not(id: self.id)

            other_users.each do |other_user|
                intersection = self.games & other_user.games
                union = self.games | other_user.games
                similarity[other_user] = intersection.size.to_f / union.size.to_f 
            end
            unless similarity.empty? then return similarity.sort_by { |key, value| value }.reverse.first(max_users) end
        end
        return similarity
    end

    def find_similar_users_euclidean(max_users)
        similarity = Hash.new(0)
        if self.games.size > 0
            other_users = self.class.all.where.not(id: self.id)
            other_users.each do |other_user|
                shared_games = self.games & other_user.games
                if shared_games.size == 0 
                    similarity[other_user] = 0
                else
                    sum_of_squares = 0
                    for i in 0..shared_games.size
                        self_score_y = get_score(shared_games[i], self).to_f
                        other_user_score_y = get_score(shared_games[i], other_user).to_f
                        for j in i+1..shared_games.size
                            self_score_x = get_score(shared_games[j], self).to_f
                            other_user_score_x = get_score(shared_games[j], other_user).to_f
                            sum_of_squares += Math.sqrt(((self_score_x - other_user_score_x).abs ** 2) + ((self_score_y - other_user_score_y).abs ** 2))
                        end
                    end
                    similarity[other_user] = 1/(1 + sum_of_squares)
                end
            end  
            unless similarity.empty? then return similarity.sort_by { |key, value| value }.reverse.first(max_users) end
        end
        return similarity
    end

    def set_similar_users(n)
        # this doesn't do anything, though the code is right (checked in irb)
        self.similarities = []
        find_similar_users_jaccard(n).each do |user, sc|
            self.similar_users.push(user)
            similarity = self.similarities.last
            similarity.score = sc
            similarity.save!
            # Similarity.new(:user_id => self.id, :user_id => user.id, :similarity => score)
        end
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

    private

    def get_score(game, user)

        review_for_current_game = user.reviews.find { |r| r.game == game }
        if review_for_current_game.nil?
            puts "GET SCORE = 2"
            return 2
        elsif review_for_current_game.recommended?
            puts "GET SCORE = 3"
            return 3
        else
            puts "GET SCORE = 1"
            return 1
        end
    end
end