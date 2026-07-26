class City < ApplicationRecord
  belongs_to :province, optional: true

  has_many :organizers, dependent: :nullify
  has_many :vacancies, dependent: :nullify

  validates :name, presence: true
end
