json.extract! credit_card, :id, :first_name, :last_name, :number, :expiration_month, :expiration_year, :card_security_code, :user_id, :created_at, :updated_at
json.url credit_card_url(credit_card, format: :json)
