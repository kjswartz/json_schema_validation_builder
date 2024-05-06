# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaPropertyFieldObject, type: :model do
  let(:validation_schema) { FactoryBot.create(:validation_schema) }
  let(:object_property)   { FactoryBot.create(
    :schema_property_field,
    :object_type,
    name: "address",
    title: "Address",
    description: "Enter your address",
    required: true,
    validation_schema: validation_schema
  )}

  describe "#to_schema_property" do
    it "builds validation schema object property" do
      expect(object_property.to_schema_property).to eq({
        "description" => "Enter your address",
        "title"       => "Address",
        "type"        => "object"
      })
    end
  end

  describe "#to_schema_property_obj" do
    it "builds validation schema object property with name field" do
      expect(object_property.to_schema_property_obj).to eq({
        "address" => {
          "description" => "Enter your address",
          "title"       => "Address",
          "type"        => "object"
        }
      })
    end
  end

  describe "field_details#SchemaSerializer::ObjectDetails" do
    context "with valid params" do
      let(:object_property)  { FactoryBot.create(
        :schema_property_field,
        :object_type,
        name: "address",
        title: "Address",
        description: "Enter your address",
        required: true,
        validation_schema: validation_schema,
        field_details: SchemaSerializer::ObjectDetails.new(
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
        )
      )}

      describe "SchemaPropertyFieldObject#to_schema_property" do
        it "builds complete object specific validation properties" do
          expect(object_property.to_schema_property).to eq({
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
          })
        end
      end
    end

    context "with non valid params" do
      it "raises ActiveRecord::RecordInvalid" do
        expect { FactoryBot.create(
          :schema_property_field,
          :object_type,
          name: "address",
          title: "Address",
          description: "Enter your address",
          required: true,
          validation_schema: validation_schema,
          field_details: SchemaSerializer::ObjectDetails.new(properties: "five")
        ) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
