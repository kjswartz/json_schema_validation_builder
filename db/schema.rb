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

ActiveRecord::Schema[7.1].define(version: 2025_09_28_162549) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "schema_property_fields", force: :cascade do |t|
    t.bigint "validation_schema_id", null: false
    t.string "type"
    t.string "name", null: false
    t.string "title"
    t.string "description"
    t.boolean "required", default: false
    t.jsonb "field_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["validation_schema_id"], name: "index_schema_property_fields_on_validation_schema_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "validation_schemas", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "title"
    t.jsonb "all_of"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_validation_schemas_on_user_id"
  end

  add_foreign_key "schema_property_fields", "validation_schemas"
  add_foreign_key "validation_schemas", "users"
end
