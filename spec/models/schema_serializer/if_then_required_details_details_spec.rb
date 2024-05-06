# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaSerializer::IfThenRequiredDetails, type: :model do
  describe "#to_schema_property" do
    let(:if_then_required_details) { SchemaSerializer::IfThenRequiredDetails.new(
      property_name: "a",
      property_const: true,
      then_required: ["b"],
      else_required: ["c"]
    ) }
    it "builds If Then Required details" do
      expect(if_then_required_details.to_schema_property).to eq({
        "if"   => { "properties" => { "a" => { "const" => true } } },
        "then" => { "required"   => ["b"] },
        "else" => { "required"   => ["c"] }
      })
    end
  end

  describe "validations" do
    it "validates only attr_accessor properties passed" do
      expect {
        SchemaSerializer::IfThenRequiredDetails.new(name: "not valid")
      }.to raise_error(NoMethodError)
    end
  end
end
