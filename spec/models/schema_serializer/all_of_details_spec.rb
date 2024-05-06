# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaSerializer::AllOfDetails, type: :model do
  let(:all_of_details) { SchemaSerializer::AllOfDetails.new(
    properties: [
      {
        "type" => "IfThenRequiredDetails",
        "class_attributes" => {
          "property_name"   => "a",
          "property_const"  => true,
          "then_required"   => ["b"],
          "else_required"   => ["c"]
        },
      },
      {
        "type" => "OneOfRequiredDetails",
        "class_attributes" => {
          "required_properties" => [["d"], ["e", "f"]]
        },
      }
    ]
  ) }
  describe "#to_schema_property" do
    it "builds All Of details" do
      expect(all_of_details.to_schema_property).to eq([
        {
          "if"   => { "properties" => { "a" => { "const" => true } } },
          "then" => { "required"   => ["b"] },
          "else" => { "required"   => ["c"] }
        },
        {
          "oneOf" => [
            {
              "required" => ["d"]
            },
            {
              "required" => ["e", "f"]
            }
          ]
        }
      ])
    end
  end

  describe "#to_schema_property_obj" do
    it "builds All Of details with allOf key" do
      expect(all_of_details.to_schema_property_obj).to eq({
        "allOf" => [
          {
            "if"   => { "properties" => { "a" => { "const" => true } } },
            "then" => { "required"   => ["b"] },
            "else" => { "required"   => ["c"] }
          },
          {
            "oneOf" => [
              {
                "required" => ["d"]
              },
              {
                "required" => ["e", "f"]
              }
            ]
          }
        ]
      })
    end
  end

  describe "validations" do
    it "validates only attr_accessor properties passed" do
      expect {
        SchemaSerializer::AllOfDetails.new(name: "not valid")
      }.to raise_error(NoMethodError)
    end
  end
end
