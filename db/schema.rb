# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_01_020000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "cities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city_type"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "postal_code"
    t.uuid "province_id"
    t.datetime "updated_at", null: false
    t.index ["province_id"], name: "index_cities_on_province_id"
  end

  create_table "organizers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.uuid "city_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.string "logo_url"
    t.string "name", null: false
    t.string "organizable_type"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.integer "vacancies_count", default: 0, null: false
    t.index ["city_id"], name: "index_organizers_on_city_id"
    t.index ["name"], name: "index_organizers_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["organizable_type"], name: "index_organizers_on_organizable_type"
  end

  create_table "provinces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_programs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_programs_vacancies", id: false, force: :cascade do |t|
    t.uuid "study_program_id", null: false
    t.uuid "vacancy_id", null: false
    t.index ["study_program_id", "vacancy_id"], name: "idx_study_programs_vacancies"
    t.index ["vacancy_id", "study_program_id"], name: "idx_vacancies_study_programs", unique: true
  end

  create_table "vacancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.integer "approved_quantity", default: 0, null: false
    t.uuid "city_id"
    t.decimal "competitive_score", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.string "days_off", default: [], null: false, array: true
    t.string "education_levels", default: [], null: false, array: true
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.decimal "opportunity_score", precision: 8, scale: 2
    t.uuid "organizer_id", null: false
    t.string "position_name", null: false
    t.uuid "primary_study_program_id"
    t.datetime "published_at"
    t.integer "quantity_needed", default: 0, null: false
    t.text "task_description"
    t.integer "total_applications", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "working_days_per_week"
    t.index ["city_id"], name: "index_vacancies_on_city_id"
    t.index ["education_levels"], name: "index_vacancies_on_education_levels", using: :gin
    t.index ["organizer_id", "published_at"], name: "index_vacancies_on_organizer_and_published_at"
    t.index ["organizer_id"], name: "index_vacancies_on_organizer_id"
    t.index ["position_name"], name: "index_vacancies_on_position_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["primary_study_program_id"], name: "index_vacancies_on_primary_study_program_id"
    t.index ["published_at"], name: "index_vacancies_on_published_at"
    t.check_constraint "approved_quantity >= 0", name: "approved_quantity_non_negative"
    t.check_constraint "competitive_score IS NULL OR competitive_score >= 0::numeric", name: "competitive_score_non_negative"
    t.check_constraint "latitude IS NULL OR latitude >= '-90'::integer::numeric AND latitude <= 90::numeric", name: "valid_latitude"
    t.check_constraint "longitude IS NULL OR longitude >= '-180'::integer::numeric AND longitude <= 180::numeric", name: "valid_longitude"
    t.check_constraint "opportunity_score IS NULL OR opportunity_score >= 0::numeric", name: "opportunity_score_non_negative"
    t.check_constraint "quantity_needed >= 0", name: "quantity_needed_non_negative"
    t.check_constraint "total_applications >= 0", name: "total_applications_non_negative"
    t.check_constraint "working_days_per_week IS NULL OR working_days_per_week >= 1 AND working_days_per_week <= 7", name: "valid_working_days_per_week"
  end

  add_foreign_key "cities", "provinces"
  add_foreign_key "organizers", "cities"
  add_foreign_key "study_programs_vacancies", "study_programs", on_delete: :cascade
  add_foreign_key "study_programs_vacancies", "vacancies", on_delete: :cascade
  add_foreign_key "vacancies", "cities"
  add_foreign_key "vacancies", "organizers"
  add_foreign_key "vacancies", "study_programs", column: "primary_study_program_id"
end
