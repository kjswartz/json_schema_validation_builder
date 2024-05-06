# frozen_string_literal: true

=begin
**Required Params**
properties: is Array of PropertyType hashes

**PropertyType Hash Required Params**
type: inclusion in SchemaPropertyField types
class_attributes: validated against SchemaPropertyField model minus validation_schema relationship


**Example**
**if using standalone use string hash keys**
SchemaSerializer::AllOfDetails.new(
  properties: [
    {
      "type" => "IfThenRequiredDetails",
      "class_attributes" => {
        "property_name"   => "resident",
        "property_const"  => true,
        "then_required"   => ["currentResident"],
        "else_required"   => ["nonResident"]
      },
    },
    {
      "type" => "OneOfRequiredDetails",
      "class_attributes" => {
        "required_properties" => [["passport"], ["drivers_license", "birth_certificate"]]
      },
    }
  ]
)
=end

class SchemaSerializer::AllOfDetails
  include ActiveModel::Validations
  include Serializable

  REQUIRED_VALID_PROPERTY_KEYS = ["type", "class_attributes"].freeze
  VALID_TYPE_CLASSES = [
    "IfThenRequiredDetails",
    "OneOfRequiredDetails",
  ].freeze

  attr_accessor :properties

  validates :properties, presence: true
  validate :properties_field, if: -> { properties.present? }

  def to_schema_property
    return unless valid?
    properties.map do |property|
      klass = "SchemaSerializer::#{property["type"]}".constantize.new(property["class_attributes"])
      klass.to_schema_property
    end
  end

  def to_schema_property_obj
    {
      "allOf" => to_schema_property
    }
  end


  private
    def validate_property_keys(property)
      # check required keys present
      REQUIRED_VALID_PROPERTY_KEYS.each { |k| errors.add(:properties, "#{k} is a required property") if property.keys.exclude?(k) }
      # check only permitted keys present
      property.keys.each { |k| errors.add(:properties, "#{k} is not a permitted property") if REQUIRED_VALID_PROPERTY_KEYS.exclude?(k) }
    end

    def validate_property_type(property)
      unless VALID_TYPE_CLASSES.include?(property["type"])
        errors.add(:properties, "#{property["type"]} is not a valid type class")
      end
    end

    def validate_property_class_attributes(property)
      if property["class_attributes"].present?
        klass = "SchemaSerializer::#{property["type"]}".constantize.new(property["class_attributes"])
        unless klass.valid?
          klass.errors.messages.each { |k, v| errors.add(k, v&.first) }
        end
      else
        errors.add(:properties_class_attributes, "#{property["type"]} is missing required class_attributes")
      end
    end

    def validate_property(property)
      validate_property_keys(property)
      return if errors.size > 0
      validate_property_type(property)
      return if errors.size > 0
      validate_property_class_attributes(property)
    end

    def properties_field
      if properties.is_a?(Array)
        classes = properties.collect(&:class).uniq
        if classes.length > 1 || classes[0] != Hash
          errors.add(:properties, "Wrong type, expected Array<Hash>")
        else
          properties.each { |p| validate_property(p) }
        end
      else
        errors.add(:properties, "Wrong type, expected Array<Hash>")
      end
    end
end
