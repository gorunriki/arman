class AddVacancySearchIndexes < ActiveRecord::Migration[8.1]
  def up
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    add_index :vacancies, :position_name, using: :gin, opclass: :gin_trgm_ops, name: "index_vacancies_on_position_name_trigram"
    add_index :vacancies, :education_levels, using: :gin
  end

  def down
    remove_index :vacancies, :education_levels
    remove_index :vacancies, name: "index_vacancies_on_position_name_trigram"
  end
end
