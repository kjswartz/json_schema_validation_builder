# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaSerializer::ArrayDetails, type: :model do
  describe "#to_schema_property" do
    let(:array_details) {
      SchemaSerializer::ArrayDetails.new(min_items: 1, max_items: 5, unique_items: true, 
        item: {
          "type" => "SchemaPropertyFieldString",
          "class_attributes" => { "name" => "alias"},
          "field_details" => { "min_length" => 1 }
        }
      )
    }
    it "builds Array details" do
      expect(array_details.to_schema_property).to eq({
        "minItems"    => 1,
        "maxItems"    => 5,
        "uniqueItems" => true,
        "items"       => {
          "minLength"   => 1,
          "type"        => "string"
        }
      })
    end
  end

  describe "validations" do
    let(:item) {{
      "type" => "SchemaPropertyFieldString",
      "class_attributes" => { "name" => "alias", "description" => "List of aliases", "title" => "Aliases", "required" => true },
      "field_details" => { "min_length" => 1 }
    }}

    it "validates only attr_accessor properties passed" do
      expect {
        SchemaSerializer::ArrayDetails.new(name: "not valid")
      }.to raise_error(NoMethodError)
    end

    it "validates min_items less than max_items" do
      expect(SchemaSerializer::ArrayDetails.new(min_items: 5, max_items: 2, item: item).valid?).to eq(false)
      expect(SchemaSerializer::ArrayDetails.new(min_items: 2, max_items: "5", item: item).valid?).to eq(true)
      expect(SchemaSerializer::ArrayDetails.new(min_items: 2, item: item).valid?).to eq(true)
      expect(SchemaSerializer::ArrayDetails.new(max_items: 5, item: item).valid?).to eq(true)
    end

    it "validates only attr_accessor properties passed" do
      expect {
        SchemaSerializer::ArrayDetails.new(name: "not valid")
      }.to raise_error(NoMethodError)
    end

    it "validates#unique_items inclusion" do
      expect(SchemaSerializer::ArrayDetails.new(unique_items: "true", item: item).valid?).to eq(false)
      expect(SchemaSerializer::ArrayDetails.new(unique_items: true, item: item).valid?).to eq(true)
      expect(SchemaSerializer::ArrayDetails.new(unique_items: false, item: item).valid?).to eq(true)
    end
  end
end
