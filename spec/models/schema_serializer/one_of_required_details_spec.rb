# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchemaSerializer::OneOfRequiredDetails, type: :model do
  describe "#to_schema_property" do
    let(:one_of_required_details) { SchemaSerializer::OneOfRequiredDetails.new(required_properties: [["a"], ["b", "c"]]) }
    it "builds One Of Required details" do
      expect(one_of_required_details.to_schema_property).to eq({
        "oneOf" => [
          {
            "required" => ["a"]
          },
          {
            "required" => ["b", "c"]
          }
        ]
      })
    end
  end

  describe "validations" do
    it "validates only attr_accessor properties passed" do
      expect {
        SchemaSerializer::OneOfRequiredDetails.new(name: "not valid")
      }.to raise_error(NoMethodError)
    end
  end
end
