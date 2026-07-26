class StudyProgram < ApplicationRecord
  has_many :primary_vacancies, class_name: "Vacancy", foreign_key: "study_program_id", dependent: :nullify
  has_and_belongs_to_many :vacancies
  validates :name, presence: true
end
