# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaPropertyFieldNumber, type: :model do
  let(:validation_schema) { FactoryBot.create(:validation_schema) }
  let(:number_property)   { FactoryBot.create(
    :schema_property_field,
    :number_type,
    name: "age",
    title: "Age",
    description: "How old are you?",
    required: true,
    validation_schema: validation_schema
  )}

  describe "#to_schema_property" do
    it "builds validation schema number property" do
      expect(number_property.to_schema_property).to eq({
        "description" => "How old are you?",
        "title"       => "Age",
        "type"        => "number"
      })
    end
  end

  describe "#to_schema_property_obj" do
    it "builds validation schema number property with name field" do
      expect(number_property.to_schema_property_obj).to eq({
        "age" => {
          "description" => "How old are you?",
          "title"       => "Age",
          "type"        => "number"
        }
      })
    end
  end

  describe "field_details#SchemaSerializer::NumberDetails" do
    context "with valid params" do
      let(:number_property) { FactoryBot.create(
        :schema_property_field,
        :number_type,
        name: "age",
        title: "Age",
        description: "How old are you?",
        required: true,
        validation_schema: validation_schema,
        field_details: SchemaSerializer::NumberDetails.new(min_value: "21", max_value: 65)
      ) }

      describe "SchemaPropertyFieldNumber#to_schema_property" do
        it "builds number specific validation properties" do
          expect(number_property.to_schema_property).to eq({
            "description" => "How old are you?",
            "title"       => "Age",
            "type"        => "number",
            "minValue"    => 21,
            "maxValue"    => 65,
          })
        end
      end
    end

    context "with non valid params" do
      it "raises ActiveRecord::RecordInvalid" do
        expect { FactoryBot.create(
          :schema_property_field,
          :number_type,
          name: "age",
          title: "Age",
          description: "How old are you?",
          required: true,
          validation_schema: validation_schema,
          field_details: SchemaSerializer::NumberDetails.new(min_value: "5L")
        ) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
