class CreateVacancies < ActiveRecord::Migration[8.1]
  def change
    create_table :vacancies, id: :uuid do |t|
      t.references :organizer, type: :uuid, null: false, foreign_key: true
      t.references :city, type: :uuid, foreign_key: true
      t.references :study_program, type: :uuid, foreign_key: true
      t.string :position_name, null: false
      t.integer :quantity_needed, default: 0
      t.integer :approved_quantity, default: 0
      t.integer :total_applications, default: 0
      t.text :task_description
      t.integer :working_days_per_week
      t.string :education_levels, array: true, default: []
      t.string :days_off, array: true, default: []
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.text :address
      t.datetime :published_at

      t.timestamps
    end
  end
end
