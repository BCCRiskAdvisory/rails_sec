json.users do
  json.array!(@users) do |user|
    json.extract! user, :id, :name, :email, :points, :created_at
    json.url user_url(user, format: :json)
  end
end
json.query @query
