class User < ActiveRecord::Base
  attr_accessor :remember_token

  #Attributes validations:
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255}, 
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  has_secure_password

  #Filters:
  before_save { self.email = email.downcase }

  #Relation:
  has_many :orders, dependent: :destroy

  #Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #Returns the hash digest of the given string.
  def User.encrypt_token(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  #Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.encrypt_token(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
   return false if remember_digest.nil?
   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

end
