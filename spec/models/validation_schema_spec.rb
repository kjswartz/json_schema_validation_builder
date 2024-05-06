require 'rails_helper'

RSpec.describe ValidationSchema, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe "#to_schema_property" do
    let(:validation_schema) { FactoryBot.create(:validation_schema, title: "Title", description: "My Description") }

    it "builds a json schema validation" do
      expect(validation_schema.to_schema_property).to eq({
        "title"       => "Title",
        "description" => "My Description",
      })
    end

    context "with schema_property_fields" do
      let(:string_property) { FactoryBot.build(:schema_property_field, :string_type, name: "firstName", title: "First Name", required: true) }

      it "builds a json schema validation" do
        validation_schema.schema_property_fields << string_property
        validation_schema.reload
        expect(validation_schema.to_schema_property).to eq({
          "description" => "My Description",
          "properties"  => {
            "firstName" => {
              "type"    => "string",
              "title"   => "First Name"
            }
          },
          "required" => ["firstName"],
          "title" => "Title"
        })
      end
    end

    context "with all_of field" do
      let(:first_name_property) { FactoryBot.build(:schema_property_field, :string_type, name: "firstName", title: "First Name") }
      let(:last_name_property) { FactoryBot.build(:schema_property_field, :string_type, name: "lastName", title: "Last Name") }
      let(:all_of_details) { SchemaSerializer::AllOfDetails.new(
        properties: [
          {
            "type" => "OneOfRequiredDetails",
            "class_attributes" => {
              "required_properties" => [["firstName"], ["lastName"]]
            },
          }
        ]
      ) }
      let(:validation_schema) { FactoryBot.create(:validation_schema,
        title: "Title",
        description: "My Description",
        schema_property_fields: [first_name_property, last_name_property],
        all_of: all_of_details
      ) }

      it "builds a json schema validation with allOf key" do
        expect(validation_schema.to_schema_property).to eq({
          "title" => "Title",
          "description" => "My Description",
          "properties"  => {
            "firstName" => {
              "type"    => "string",
              "title"   => "First Name"
            },
            "lastName" => {
              "type"    => "string",
              "title"   => "Last Name"
            }
          },
          "allOf" => [{
            "oneOf" => [
              {
                "required" => ["firstName"]
              },
              {
                "required" => ["lastName"]
              }
            ]
          }]
        })
      end
    end
  end
end
