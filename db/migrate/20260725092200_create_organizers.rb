class CreateOrganizers < ActiveRecord::Migration[8.1]
  def change
    # Hapus tabel organizers lama yang tidak sengaja terbuat bertipe bigint
    drop_table :organizers, if_exists: true, force: :cascade

    # Buat tabel organizers yang baru dengan UUID
    create_table :organizers, id: :uuid do |t|
      t.references :city, type: :uuid, foreign_key: true

      t.string :name, null: false
      t.string :email
      t.string :phone
      t.text :address
      t.string :organizable_type
      t.text :description
      t.string :logo_url
      t.integer :vacancies_count, default: 0, null: false

      t.timestamps
    end
  end
end
