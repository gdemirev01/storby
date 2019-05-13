json.extract! order, :id, :card_id, :ip_address, :first_name, :last_name, :card_type, :card_expires_on, :created_at, :updated_at
json.url order_url(order, format: :json)
