# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaSerializer::StringDetails, type: :model do
  describe "#to_schema_property" do
    let(:string_details) { SchemaSerializer::StringDetails.new(const: "a value", format: "email", enum: ["a", "b", "c"], pattern: "[0-9]", min_length: "5", max_length: 9) }
    it "builds string details specific validation properties" do
      expect(string_details.to_schema_property).to eq({
        "const"     => "a value",
        "format"    => "email",
        "enum"      => ["a", "b", "c"],
        "pattern"   => "[0-9]",
        "maxLength" => 9,
        "minLength" => 5,
      })
    end
  end

  describe "validations" do
    it "validates only attr_accessor properties passed" do
      expect {
        SchemaSerializer::StringDetails.new(name: "not valid")
      }.to raise_error(NoMethodError)
    end

    it "validates #const is a String" do
      expect(SchemaSerializer::StringDetails.new(const: ["not valid"]).valid?).to eq(false)
      expect(SchemaSerializer::StringDetails.new(const: "valid").valid?).to eq(true)
    end

    it "validates #patern is a String" do
      expect(SchemaSerializer::StringDetails.new(pattern: ["not valid"]).valid?).to eq(false)
      expect(SchemaSerializer::StringDetails.new(pattern: "valid").valid?).to eq(true)
    end

    it "validates #format inclusion" do
      expect(SchemaSerializer::StringDetails.new(format: "not valid").valid?).to eq(false)
      expect(SchemaSerializer::StringDetails.new(format: "email").valid?).to eq(true)
    end

    it "validates #enum is a Array<String>" do
      expect(SchemaSerializer::StringDetails.new(enum: "not valid").valid?).to eq(false)
      expect(SchemaSerializer::StringDetails.new(enum: ["not valid", 1]).valid?).to eq(false)
      expect(SchemaSerializer::StringDetails.new(enum: ["valid"]).valid?).to eq(true)
    end

    it "validates min_length less than max_length" do
      expect(SchemaSerializer::StringDetails.new(min_length: 5, max_length: 2).valid?).to eq(false)
      expect(SchemaSerializer::StringDetails.new(min_length: 2, max_length: "5").valid?).to eq(true)
      expect(SchemaSerializer::StringDetails.new(min_length: 2).valid?).to eq(true)
      expect(SchemaSerializer::StringDetails.new(max_length: 5).valid?).to eq(true)
    end
  end
end
