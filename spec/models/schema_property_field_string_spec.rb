# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaPropertyFieldString, type: :model do
  let(:validation_schema) { FactoryBot.create(:validation_schema) }
  let(:string_property)   { FactoryBot.create(
    :schema_property_field,
    :string_type,
    name: "firstName",
    title: "First Name",
    description: "First name field",
    required: true,
    validation_schema: validation_schema
  )}

  describe "#to_schema_property" do
    it "builds validation schema string property" do
      expect(string_property.to_schema_property).to eq({
        "description" => "First name field",
        "title"       => "First Name",
        "type"        => "string"
      })
    end
  end

  describe "#to_schema_property_obj" do
    it "builds validation schema string property with name field" do
      expect(string_property.to_schema_property_obj).to eq({
        "firstName" => {
          "description" => "First name field",
          "title"       => "First Name",
          "type"        => "string"
        }
      })
    end
  end

  describe "field_details#SchemaSerializer::StringDetails" do
    context "with valid params" do
      let(:string_property) { FactoryBot.create(
        :schema_property_field,
        :string_type,
        name: "firstName",
        title: "First Name",
        required: true,
        validation_schema: validation_schema,
        field_details: SchemaSerializer::StringDetails.new(const: "a value", format: "email", enum: ["a", "b", "c"], pattern: "[0-9]", min_length: "5", max_length: 9)
      )}

      describe "SchemaPropertyFieldString#to_schema_property" do
        it "builds string specific validation properties" do
          expect(string_property.to_schema_property).to eq({
            "const"     => "a value",
            "enum"      => ["a", "b", "c"],
            "format"    => "email",
            "maxLength" => 9,
            "minLength" => 5,
            "pattern"   => "[0-9]",
            "title"     => "First Name",
            "type"      => "string"
          })
        end
      end
    end

    context "with non valid params" do
      it "raises ActiveRecord::RecordInvalid" do
        expect { FactoryBot.create(
          :schema_property_field,
          :string_type,
          name: "firstName",
          title: "First Name",
          required: true,
          validation_schema: validation_schema,
          field_details: SchemaSerializer::StringDetails.new(const: ["not valid"])
        ) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
