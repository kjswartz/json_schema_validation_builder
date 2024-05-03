class ValidationSchema < ApplicationRecord
  validates :name, presence: true
end
