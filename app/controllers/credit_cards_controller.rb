class CreditCardsController < ApplicationController
  before_action :set_credit_card, only: [:show, :edit, :update, :destroy]
  before_action :restrict_access, only: [:index, :show, :edit, :update, :destroy]
  # GET /credit_cards
  # GET /credit_cards.json
  def index
    @credit_cards = CreditCard.all
  end

  # GET /credit_cards/1
  # GET /credit_cards/1.json
  def show
  end

  # GET /credit_cards/new
  def new
    @credit_card = CreditCard.new
  end

  # GET /credit_cards/1/edit
  def edit
  end

  # POST /credit_cards
  # POST /credit_cards.json
  def create
    if(CreditCard.exists?(user_id: current_user.id))
        redirect_to "/", notice: "Credit card already exists"
        return
    end
    @credit_card = CreditCard.new(credit_card_params)
    begin
    credit_card = ActiveMerchant::Billing::CreditCard.new(
            :first_name         => @credit_card.first_name,
            :last_name          => @credit_card.last_name,
            :number             => @credit_card.number,
            :month              => @credit_card.expiration_month,
            :year               => @credit_card.expiration_year,
            :verification_value => @credit_card.card_security_code)
    rescue StandardError => e
      redirect_to new_credit_card_path
      return
    end
        # Validating the card automatically detects the card type
    if !credit_card.validate.empty?
      redirect_to new_credit_card_path, notice: "Not a valid card"
      return
    end
    @credit_card.user = current_user
    print current_user
    print "aaaaaaaaa\n\n\n\n\n\n\n"
    respond_to do |format|
      if @credit_card.save
        format.html { redirect_to games_path, notice: 'Credit card was successfully created.' }
        format.json { render :index, status: :created, location: games_path }
      else
        format.html { render :new }
        format.json { render json: @credit_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /credit_cards/1
  # PATCH/PUT /credit_cards/1.json
  def update
    respond_to do |format|
      @credit_card.user = current_user
      if @credit_card.update(credit_card_params)
        format.html { redirect_to @credit_card, notice: 'Credit card was successfully updated.' }
        format.json { render :show, status: :ok, location: @credit_card }
      else
        format.html { render :edit }
        format.json { render json: @credit_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /credit_cards/1
  # DELETE /credit_cards/1.json
  def destroy
    @credit_card.destroy
    respond_to do |format|
      format.html { redirect_to credit_cards_url, notice: 'Credit card was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_credit_card
      @credit_card = CreditCard.find(params[:id])
    end

    def restrict_access
      redirect_to "/", notice: "You don't have permission to go there, sorry"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def credit_card_params
      params.require(:credit_card).permit(:first_name, :last_name, :number, :expiration_month, :expiration_year, :card_security_code)
    end
end
