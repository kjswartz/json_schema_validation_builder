# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

def build_string_property(name, title, required)
  SchemaPropertyFieldString.new(name: name, title: title, required: required)
end

def create_validation_schema(name, title, description, schema_property_fields)
  ValidationSchema.find_or_create_by!(
    name: name,
    title: title,
    description: description,
    schema_property_fields: schema_property_fields
  )
end

def create_user_signup_validation_schema
  create_validation_schema(
    "new_user",
    "New User Signup",
    "Validation schema for signing up new users",
    [
      build_string_property('firstName', 'First Name', true),
      build_string_property('lastName', 'Last Name', true),
      build_string_property('email', 'Email', true),
    ]
  )
end

create_user_signup_validation_schema
