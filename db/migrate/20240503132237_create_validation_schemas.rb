class CreateValidationSchemas < ActiveRecord::Migration[7.1]
  def change
    create_table :validation_schemas do |t|
      t.string :name, null: false
      t.string :description
      t.string :title
      t.jsonb  :all_of

      t.timestamps
    end
  end
end
