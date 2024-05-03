# frozen_string_literal: true

FactoryBot.define do
  factory :schema_property_field do
    name { "MyString" }

    trait :array_type do
      initialize_with { SchemaPropertyFieldArray.new(attributes) }
    end

    trait :boolean_type do
      initialize_with { SchemaPropertyFieldBoolean.new(attributes) }
    end

    trait :number_type do
      initialize_with { SchemaPropertyFieldNumber.new(attributes) }
    end

    trait :object_type do
      initialize_with { SchemaPropertyFieldObject.new(attributes) }
    end

    trait :string_type do
      initialize_with { SchemaPropertyFieldString.new(attributes) }
    end
  end
end
