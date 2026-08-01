class CreateJoinTableStudyProgramsVacancies < ActiveRecord::Migration[8.1]
  def change
    create_join_table :study_programs, :vacancies, column_options: { type: :uuid } do |t|
      # t.index [:study_program_id, :vacancy_id]
      # t.index [:vacancy_id, :study_program_id]
      t.index [ :vacancy_id, :study_program_id ], unique: true, name: "idx_vacancies_study_programs"
      t.index [ :study_program_id, :vacancy_id ], name: "idx_study_programs_vacancies"
    end
  end
end
