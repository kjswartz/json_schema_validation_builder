class User < ApplicationRecord
  has_secure_password
  has_many :validation_schemas, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_digest_changed?
  validates :role, inclusion: { in: %w[admin user] }

  def admin?
    role == 'admin'
  end
end