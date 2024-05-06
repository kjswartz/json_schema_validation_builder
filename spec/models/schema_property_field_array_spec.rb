# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaPropertyFieldArray, type: :model do
  let(:validation_schema) { FactoryBot.create(:validation_schema) }
  let(:array_property)    { FactoryBot.create(
    :schema_property_field,
    :array_type,
    name: "address",
    title: "Address History",
    description: "Enter last 3 addresses",
    required: true,
    validation_schema: validation_schema,
    field_details: SchemaSerializer::ArrayDetails.new(
      min_items: 3,
      max_items: 3,
      item: {
        type: "SchemaPropertyFieldObject",
        class_attributes: { name: "address", description: "Enter your address", title: "Address" },
        field_details: {
          properties: [
            {
              type: "SchemaPropertyFieldString",
              class_attributes: { name: "street", description: "Name of street", title: "Street Name", required: true },
              field_details: { min_length: 1 }
            },
            {
              type: "SchemaPropertyFieldString",
              class_attributes: { name: "city", description: "Name of city", title: "City Name", required: true },
              field_details: { min_length: 1 }
            }
          ]
        }
      }
    )
  )}

  describe "#to_schema_property" do
    it "builds validation schema array property" do
      expect(array_property.to_schema_property).to eq({
        "description" => "Enter last 3 addresses",
        "title"       => "Address History",
        "type"        => "array",
        "minItems"    => 3,
        "maxItems"    => 3,
        "items"       => {
          "description" => "Enter your address",
          "title"       => "Address",
          "type"        => "object",
          "properties"  => {
            "street" => {
              "description" => "Name of street",
              "minLength"   => 1,
              "title"       => "Street Name",
              "type"        => "string"
            },
            "city" => {
              "description" => "Name of city",
              "minLength"   => 1,
              "title"       => "City Name",
              "type"        => "string"
            },
          },
          "required" => ["street", "city"],
        }
      })
    end
  end

  describe "#to_schema_property_obj" do
    it "builds validation schema array property with name field" do
      expect(array_property.to_schema_property_obj).to eq({
        "address" => {
          "description" => "Enter last 3 addresses",
          "title"       => "Address History",
          "type"        => "array",
          "minItems"    => 3,
          "maxItems"    => 3,
          "items"       => {
            "description" => "Enter your address",
            "title"       => "Address",
            "type"        => "object",
            "properties"  => {
              "street" => {
                "description" => "Name of street",
                "minLength"   => 1,
                "title"       => "Street Name",
                "type"        => "string"
              },
              "city" => {
                "description" => "Name of city",
                "minLength"   => 1,
                "title"       => "City Name",
                "type"        => "string"
              },
            },
            "required" => ["street", "city"],
          }
        }
      })
    end
  end

  context "with non-valid params" do
    it "raises ActiveRecord::RecordInvalid" do
      expect { FactoryBot.create(
        :schema_property_field,
        :array_type,
        name: "address",
        title: "Address History",
        description: "Enter last 5 years",
        required: true,
        validation_schema: validation_schema,
        field_details: SchemaSerializer::ArrayDetails.new(min_items: "five")
      ) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
