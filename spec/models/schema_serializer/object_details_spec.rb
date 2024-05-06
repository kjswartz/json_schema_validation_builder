# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaSerializer::ObjectDetails, type: :model do
  describe "#to_schema_property" do
    let(:object_details) { SchemaSerializer::ObjectDetails.new(
      properties: [
        {
          "type"             => "SchemaPropertyFieldString",
          "class_attributes" => { "name" => "a", "title" => "a", "required" => true }
        },
        {
          "type"             => "SchemaPropertyFieldString",
          "class_attributes" => { "name" => "b", "title" => "b", "required" => true }
        },
      ],
      all_of: [
        {
          "type" => "IfThenRequiredDetails",
          "class_attributes" => {
            "property_name"   => "a",
            "property_const"  => "SE",
            "then_required"   => ["b", "c"],
            "else_required"   => ["b", "c", "d"]
          },
        },
      ]
    )}

    it "builds Object details" do
      expect(object_details.to_schema_property).to eq({
        "properties" => {
          "a" => {
            "title" => "a",
            "type"  => "string"
          },
          "b" => {
            "title" => "b",
            "type"  => "string"
          },
        },
        "allOf" => [
          {
            "if"   => { "properties" => { "a" => { "const" => "SE" } } },
            "then" => { "required"   => ["b", "c"] },
            "else" => { "required"   => ["b", "c", "d"] }
          }
        ],
        "required" => ["a", "b"],
      })
    end
  end

  describe "validations" do
    it "validates only attr_accessor properties passed" do
      expect {
        SchemaSerializer::ObjectDetails.new(name: "not valid")
      }.to raise_error(NoMethodError)
    end

    describe "#properties Array<Hash> type" do
      it "validates #type in SchemaPropertyField type" do
        object_details = SchemaSerializer::ObjectDetails.new(properties: [{
          "type"             => "SchemaPropertyFieldInteger",
          "class_attributes" => { "name" => "filename" },
        }])
        expect(object_details.valid?).to eq(false)

        object_details = SchemaSerializer::ObjectDetails.new(properties: [{
          "type"             => "SchemaPropertyFieldString",
          "class_attributes" => { "name" => "filename" },
        }])
        expect(object_details.valid?).to eq(true)

        object_details = SchemaSerializer::ObjectDetails.new(properties: [{
          "type"             => "SchemaPropertyFieldNumber",
          "class_attributes" => { "name" => "age" },
        }])
        expect(object_details.valid?).to eq(true)
      end
    end

    describe "#all_of Array<Hash> type" do
      it "validates #type in all_of types" do
        object_details = SchemaSerializer::ObjectDetails.new(
          properties: [{
            "type" => "SchemaPropertyFieldString",
            "class_attributes" => { "name" => "filename" },
          }],
          all_of: [{
            "type" => "IfDetails",
            "class_attributes" => { "name" => "filename" },
          }]
        )
        expect(object_details.valid?).to eq(false)

        object_details = SchemaSerializer::ObjectDetails.new(
          properties: [{
            "type" => "SchemaPropertyFieldString",
            "class_attributes" => { "name" => "filename" },
          }],
          all_of: [{
            "type"             => "IfThenRequiredDetails",
            "class_attributes" => {
              "property_name"  => "a",
              "property_const" => "SE",
              "then_required"  => ["a", "b"],
              "else_required"  => ["a", "b", "c"]
            },
          }]
        )
        expect(object_details.valid?).to eq(true)

        object_details = SchemaSerializer::ObjectDetails.new(
          properties: [{
            "type"             => "SchemaPropertyFieldString",
            "class_attributes" => { "name" => "filename" },
          }],
          all_of: [{
            "type"             => "OneOfRequiredDetails",
            "class_attributes" => {
              "required_properties" => [["a"], ["b", "c"]]
            },
          }]
        )
        expect(object_details.valid?).to eq(true)
      end
    end
  end
end
