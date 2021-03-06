require './lib/recommendation.rb'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :omniauthable, omniauth_providers: %i[facebook]

  enum role: [:user, :developer, :admin]
  after_initialize :set_default_role, :if => :new_record?
  private
  def set_default_role
    self.role ||= :user
  end
  has_one :credit_card, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one_attached :profile_pic, dependent: :destroy

  has_and_belongs_to_many :games, dependent: :destroy

  has_many :similarities, foreign_key: :user_a_id, :dependent => :destroy
  has_many(:reverse_similarities, :class_name => :Similarity,
      :foreign_key => :user_b_id, :dependent => :destroy)
  has_many :similar_users, :class_name => "User", through: :similarities, :source => :user_b

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      require 'open-uri'
      url = URI.parse(auth.info.image)
      image = open(url)

      ActiveRecord::Base.connection_pool.with_connection do
        user.profile_pic.attach(
          io: image, 
          filename: user.email + ".png", 
          content_type: "image/png"
        )
      end

      # user.name = auth.info.name   # assuming the user model has a name
      # user.profile_pic = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails, 
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  include Recommendation
end
