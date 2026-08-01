class StudyProgram < ApplicationRecord
  has_many :primary_vacancies, class_name: "Vacancy", foreign_key: "primary_study_program_id", inverse_of: :primary_study_program, dependent: :nullify
  has_and_belongs_to_many :vacancies
  validates :name, presence: true
end
