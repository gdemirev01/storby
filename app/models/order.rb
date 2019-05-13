
class Order < ActiveRecord::Base
  belongs_to :game
  has_many :transactions, :class_name => "OrderTransaction"
  
  attr_accessor :card_number, :card_verification
  
  before_create :validate_card

  def purchase
    response = GATEWAY.purchase(price_in_cents, credit_card, purchase_options)

	if response.success?
		puts "Successfully charged $#{sprintf("%.2f", amount / 100)} to the credit card #{credit_card.display_number}"
	else
		raise StandardError, response.message 
	end
    transactions.create!(:action => "purchase", :amount => price_in_cents, :response => response)
    game.update_attribute(:purchased_at, Time.now) if response.success?
    response.success?
  end
  
  def price_in_cents
    (game.price*100).round
  end

  private
  
  def purchase_options
    {
      :ip => ip_address,
      :billing_address => {
        :name     => "Ryan Bates",
        :address1 => "123 Main St.",
        :city     => "New York",
        :state    => "NY",
        :country  => "US",
        :zip      => "10001"
      }
    }
  end
  
  def validate_card

    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        this.errors.add(message)
      end
    end
  end
  
  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type               => card_type,
      :number             => card_number,
      :verification_value => card_verification,
      :month              => card_expires_on.month,
      :year               => card_expires_on.year,
      :first_name         => first_name,
      :last_name          => last_name
    )
  end
end
