FactoryBot.define do
  factory :user do
    name { "John" } # Starts with capital, >= 3 chars, no digits/special chars
    email { "john@gmail.com" } # Valid domain
    password { "Password123!" } # >= 8 chars, 1 uppercase, 1 lowercase, 1 special char
    mobile_number { "9876543210" } # 10-digit number starting with 9
  end
end