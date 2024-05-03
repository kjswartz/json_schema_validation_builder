# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaPropertyFieldBoolean, type: :model do
  let(:validation_schema) { FactoryBot.create(:validation_schema) }
  let(:boolean_property)  { FactoryBot.create(
    :schema_property_field,
    :boolean_type,
    name: "optIn",
    title: "Sign up for newsletter",
    description: "Do you wish to receive weekly emails?",
    required: true,
    validation_schema: validation_schema
  )}

  describe "#to_schema_property" do
    it "builds validation schema boolean property" do
      expect(boolean_property.to_schema_property).to eq({
        "description" => "Do you wish to receive weekly emails?",
        "title"       => "Sign up for newsletter",
        "type"        => "boolean"
      })
    end
  end

  describe "#to_schema_property_obj" do
    it "builds validation schema boolean property with name field" do
      expect(boolean_property.to_schema_property_obj).to eq({
        "optIn" => {
          "description" => "Do you wish to receive weekly emails?",
          "title"       => "Sign up for newsletter",
          "type"        => "boolean"
        }
      })
    end
  end

  describe "field_details#SchemaSerializer::BooleanDetails" do
    context "with valid params" do
      let(:boolean_property) { FactoryBot.create(
        :schema_property_field,
        :boolean_type,
        name: "optIn",
        title: "Enroll",
        required: true,
        validation_schema: validation_schema,
        field_details: SchemaSerializer::BooleanDetails.new(const: true)
      )}

      describe "SchemaPropertyFieldBoolean#to_schema_property" do
        it "builds boolean specific validation properties" do
          expect(boolean_property.to_schema_property).to eq({
            "const"     => true,
            "title"     => "Enroll",
            "type"      => "boolean"
          })
        end
      end
    end

    context "with non valid params" do
      it "raises ActiveRecord::RecordInvalid" do
        expect { FactoryBot.create(
          :schema_property_field,
          :boolean_type,
          name: "optIn",
          title: "Enroll",
          required: true,
          validation_schema: validation_schema,
          field_details: SchemaSerializer::BooleanDetails.new(const: "true")
        ) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
