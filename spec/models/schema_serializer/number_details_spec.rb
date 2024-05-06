# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaSerializer::NumberDetails, type: :model do
  describe "#to_schema_property" do
    let(:number_details) { SchemaSerializer::NumberDetails.new(min_value: "5", max_value: 10) }
    it "builds Number details" do
      expect(number_details.to_schema_property).to eq({
        "minValue" => 5,
        "maxValue" => 10,
      })
    end
  end

  describe "validations" do
    it "validates only attr_accessor properties passed" do
      expect {
        SchemaSerializer::NumberDetails.new(name: "not valid")
      }.to raise_error(NoMethodError)
    end

    it "validates min_value less than max_value" do
      expect(SchemaSerializer::NumberDetails.new(min_value: 5, max_value: 2).valid?).to eq(false)
      expect(SchemaSerializer::NumberDetails.new(min_value: 2, max_value: "5").valid?).to eq(true)
      expect(SchemaSerializer::NumberDetails.new(max_value: 5).valid?).to eq(true)
      expect(SchemaSerializer::NumberDetails.new(min_value: 2).valid?).to eq(true)
    end
  end
end
