json.extract! request, :id, :text, :approved, :user, :created_at, :updated_at
json.url request_url(request, format: :json)
