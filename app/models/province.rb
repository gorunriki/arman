class Province < ApplicationRecord
  has_many :cities, dependent: :nullify

  validates :name, presence: true
end
