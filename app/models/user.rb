class User < ApplicationRecord
  has_secure_password

  VALID_EMAIL_DOMAINS = /\A[\w+\-.]+@(gmail|yahoo|hotmail|outlook|aol|icloud)\.com\z/i
  VALID_PASSWORD_FORMAT = /\A(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#\$%^&*])(?!.*\s).{8,}\z/


  validates :name, presence: true, format: {with: /\A[A-Z][a-zA-Z]{2,}\z/, message: "must start with capital, be at least 3 characters long, and contains no digits or any special characters"}


  validates :email,uniqueness: true, format: { with: VALID_EMAIL_DOMAINS, message: "must be from a valid domain (e.g., gmail.com, yahoo.com)" }


  validates :password, format: { with: VALID_PASSWORD_FORMAT, message: "must be at least 8 characters long and include 1 uppercase letter, 1 lowercase letter, and 1 special character (!@#$%^&*)" }

  validates :mobile_number,uniqueness: true, format: { with: /\A[6-9]\d{9}\z/, message: "must be a 10-digit number starting with 6, 7, 8, or 9" }


end