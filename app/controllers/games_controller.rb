class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy, :add_to_user]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
    @search = params["search"]
    puts(@search)
    if @search.present?
      puts(@search[:name])
      @name = @search[:name]
      @games = Game.where("LOWER(name) LIKE ?", "%#{@name.downcase}%")
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @review = Review.new
    @reviews = @game.reviews
    @allowed_to_leave_review = true;
    @reviews.each do |r|
      if r.user == current_user
        @allowed_to_leave_review = false
        break
      end
    end
  end

  # GET /games/new
  def new
    @statusTypes = ["Relesed", "Beta", "Alpha"]
    @genres = Game.genres.each.map { |g| g[0]}
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)
    @game.imageCounter = params[:game][:images].length

    if(params[:game][:status] != "Relesed")
      @game.relese_date = params[:game][:relese_date]
    end
    respond_to do |format|
      if @game.save
        counterForImages = 1
        params[:game][:images].each do |image|
          Cloudinary::Uploader.upload(image.tempfile.path, 
          :folder => "storby/" + params[:game][:name], :public_id => counterForImages.to_s, :overwrite => true, 
          :resource_type => "image")
          counterForImages += 1
        end
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  # def update
  #   puts("BLBAABLBALAB")
  #   respond_to do |format|
  #     if @game.update(game_params)
  #       format.html { redirect_to @game, notice: 'Game was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @game }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @game.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_to_user 

    if user_signed_in?
      user = User.find(current_user.id)
      puts(current_user.id)

      require 'active_merchant'

      # Use the TrustCommerce test servers
      ActiveMerchant::Billing::Base.mode = :test

      gateway = ActiveMerchant::Billing::PaypalGateway.new(
                  login: 'gdemirev78-facilitator_api1.gmail.com',
                  password: '9UFBFWS8KFDDA8H4',
                  signature: "AyGU4EPrteLs4B5-UwCtU9CWOZJyA6gqvbzYkHKJOBU-S7oY4QgOjawb")

      # ActiveMerchant accepts all amounts as Integer values in cents
      amount = @game.price * 100  # $10.00

      card = CreditCard.find_by user: user

      # The card verification value is also known as CVV2, CVC2, or CID
      credit_card = ActiveMerchant::Billing::CreditCard.new(
                      :first_name         => card.first_name,
                      :last_name          => card.last_name,
                      :number             => card.number,
                      :month              => card.expiration_month,
                      :year               => card.expiration_year,
                      :verification_value => card.card_security_code)

      # Validating the card automatically detects the card type
      if credit_card.validate.empty?
        # Capture $10 from the credit card
        response = gateway.purchase(amount, credit_card, options = {ip: "127.0.0.1"})

        if response.success?
          puts "Successfully charged $#{sprintf("%.2f", amount / 100)} to the credit card #{credit_card.display_number}"
        else
          raise StandardError, response.message
        end
      end

      @game.users << user
      if @game.save
        respond_to do |format|
          format.html { redirect_to @game, notice: 'Game was successfully added to your library.' }
          format.json { render :show, status: :ok, location: @game }
        end
      else 
        respond_to do |format|
          format.html { redirect_to @game, notice: 'Something went wrong! Game was not added to your library.' }
        end
      end
    else 
      respond_to do |format|
        format.html { redirect_to @game, alert: 'You are not currently logged in!' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
      @genres = Game.genres.each.map { |g| g[0]}
      @statusTypes = ["Relesed", "Beta", "Alpha"]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:name, :desc, :price, :genre, :status, :search, source: [],)
    end
end
