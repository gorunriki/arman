class CreateOrganizers < ActiveRecord::Migration[8.1]
  def change
    create_table :organizers, id: :uuid do |t|
      t.references :city, type: :uuid, foreign_key: true

      t.string :name, null: false
      t.string :email
      t.string :phone
      t.text :address
      t.string :organizable_type
      t.text :description
      t.string :logo_url

      t.timestamps
    end
  end
end
