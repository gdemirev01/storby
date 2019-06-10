require 'sidekiq-scheduler'

class HardWorker
  include Sidekiq::Worker

  def perform()
    # Recalculate similar users
    User.all.each do |user|
      user.set_similar_users(5)
    end
  end
end
