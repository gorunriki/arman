class Vacancy < ApplicationRecord
  belongs_to :organizer, counter_cache: true
  belongs_to :city, optional: true
  belongs_to :primary_study_program, class_name: "StudyProgram", optional: true
  has_and_belongs_to_many :study_programs
  validates :position_name, presence: true
  scope :active, -> { where("published_at <= ?", Time.current) }
end
