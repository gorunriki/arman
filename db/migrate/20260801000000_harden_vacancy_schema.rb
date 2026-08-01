class HardenVacancySchema < ActiveRecord::Migration[8.1]
  def up
    add_column :organizers, :vacancies_count, :integer, default: 0, null: false unless column_exists?(:organizers, :vacancies_count)

    execute <<~SQL.squish
      UPDATE organizers
      SET vacancies_count = (
        SELECT COUNT(*)
        FROM vacancies
        WHERE vacancies.organizer_id = organizers.id
      )
    SQL

    rename_column :vacancies, :study_program_id, :primary_study_program_id
    add_column :vacancies, :competitive_score, :decimal, precision: 8, scale: 2
    add_column :vacancies, :opportunity_score, :decimal, precision: 8, scale: 2

    change_column_null :provinces, :name, false, "Unknown Province"
    change_column_null :cities, :name, false, "Unknown City"
    change_column_null :study_programs, :name, false, "Unknown Program"
    change_column_null :vacancies, :quantity_needed, false, 0
    change_column_null :vacancies, :approved_quantity, false, 0
    change_column_null :vacancies, :total_applications, false, 0
    change_column_null :vacancies, :education_levels, false, []
    change_column_null :vacancies, :days_off, false, []

    add_index :vacancies, :published_at

    add_check_constraint :vacancies, "quantity_needed >= 0", name: "quantity_needed_non_negative"
    add_check_constraint :vacancies, "approved_quantity >= 0", name: "approved_quantity_non_negative"
    add_check_constraint :vacancies, "total_applications >= 0", name: "total_applications_non_negative"
    add_check_constraint :vacancies, "competitive_score IS NULL OR competitive_score >= 0", name: "competitive_score_non_negative"
    add_check_constraint :vacancies, "opportunity_score IS NULL OR opportunity_score >= 0", name: "opportunity_score_non_negative"
    add_check_constraint :vacancies, "working_days_per_week IS NULL OR working_days_per_week BETWEEN 1 AND 7", name: "valid_working_days_per_week"
    add_check_constraint :vacancies, "latitude IS NULL OR latitude BETWEEN -90 AND 90", name: "valid_latitude"
    add_check_constraint :vacancies, "longitude IS NULL OR longitude BETWEEN -180 AND 180", name: "valid_longitude"

    add_foreign_key :study_programs_vacancies, :vacancies, on_delete: :cascade
    add_foreign_key :study_programs_vacancies, :study_programs, on_delete: :cascade
  end

  def down
    remove_foreign_key :study_programs_vacancies, :study_programs
    remove_foreign_key :study_programs_vacancies, :vacancies

    remove_check_constraint :vacancies, name: "valid_longitude"
    remove_check_constraint :vacancies, name: "valid_latitude"
    remove_check_constraint :vacancies, name: "valid_working_days_per_week"
    remove_check_constraint :vacancies, name: "opportunity_score_non_negative"
    remove_check_constraint :vacancies, name: "competitive_score_non_negative"
    remove_check_constraint :vacancies, name: "total_applications_non_negative"
    remove_check_constraint :vacancies, name: "approved_quantity_non_negative"
    remove_check_constraint :vacancies, name: "quantity_needed_non_negative"

    remove_index :vacancies, :published_at

    change_column_null :vacancies, :days_off, true
    change_column_null :vacancies, :education_levels, true
    change_column_null :vacancies, :total_applications, true
    change_column_null :vacancies, :approved_quantity, true
    change_column_null :vacancies, :quantity_needed, true
    change_column_null :study_programs, :name, true
    change_column_null :cities, :name, true
    change_column_null :provinces, :name, true

    remove_column :vacancies, :opportunity_score
    remove_column :vacancies, :competitive_score
    rename_column :vacancies, :primary_study_program_id, :study_program_id
    remove_column :organizers, :vacancies_count
  end
end
