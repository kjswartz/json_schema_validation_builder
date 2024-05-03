class CreateSchemaPropertyFields < ActiveRecord::Migration[7.1]
  def change
    create_table :schema_property_fields do |t|
      t.references :validation_schema, null: false, foreign_key: true
      t.string     :type
      t.string     :name, null: false
      t.string     :title
      t.string     :description
      t.boolean    :required, default: false
      t.jsonb      :field_details

      t.timestamps
    end
  end
end
