class AddOrganizerSearchIndexes < ActiveRecord::Migration[8.1]
  def up
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    add_index :organizers, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_organizers_on_name_trigram"
    add_index :organizers, :organizable_type
    add_index :vacancies, [ :organizer_id, :published_at ], name: "index_vacancies_on_organizer_and_published_at"
  end

  def down
    remove_index :vacancies, name: "index_vacancies_on_organizer_and_published_at"
    remove_index :organizers, :organizable_type
    remove_index :organizers, name: "index_organizers_on_name_trigram"
  end
end
