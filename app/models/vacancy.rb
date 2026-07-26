class Vacancy < ApplicationRecord
  belongs_to :organizer
  belongs_to :city, optional: true
  belongs_to :study_program, optional: true
  has_and_belongs_to_many :study_programs
  validates :position_name, presence: true
  scope :active, -> { where("published_at <= ?", Time.current) }
end
