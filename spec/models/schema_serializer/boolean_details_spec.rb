# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaSerializer::BooleanDetails, type: :model do
  describe "#to_schema_property" do
    let(:boolean_details) { SchemaSerializer::BooleanDetails.new(const: true) }
    it "builds Boolean details" do
      expect(boolean_details.to_schema_property).to eq({ "const" => true })
    end
  end

  describe "validations" do
    it "validates only attr_accessor properties passed" do
      expect {
        SchemaSerializer::BooleanDetails.new(name: "not valid")
      }.to raise_error(NoMethodError)
    end

    it "validates #const inclusion" do
      expect(SchemaSerializer::BooleanDetails.new(const: "true").valid?).to eq(false)
      expect(SchemaSerializer::BooleanDetails.new(const: true).valid?).to eq(true)
      expect(SchemaSerializer::BooleanDetails.new(const: false).valid?).to eq(true)
    end
  end
end
