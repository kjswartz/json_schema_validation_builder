# frozen_string_literal: true

=begin
**INFO**
PropertyType {
  type: inclusion in SchemaPropertyField types
  class_attributes: validated against SchemaPropertyField model minus validation_schema relationship
  field_details?: validated against SchemaPropertyField type field_details serializer
}

properties is Array of PropertyType hashes

**Example**
SchemaPropertyFieldObject.new(
  name: "address",
  title: "Address",
  description: "Enter your address",
  field_details: SchemaSerializer::ObjectDetails.new(
    properties: [
      {
        type: "SchemaPropertyFieldString",
        class_attributes: { name: "street", description: "Name of street", title: "Street Name", required: true },
        field_details: { min_length: 1 }
      },
      {
        type: "SchemaPropertyFieldString",
        class_attributes: { name: "city", description: "Name of city", title: "City Name", required: true },
        field_details: { min_length: 1 }
      }
    ],
  )
)
=end

class SchemaSerializer::ObjectDetails
  include ActiveModel::Validations
  include Serializable

  REQUIRED_VALID_PROPERTY_KEYS = ["type", "class_attributes"].freeze
  OPTIONAL_VALID_PROPERTY_KEYS = ["field_details"].freeze
  VALID_PROPERTY_KEYS = REQUIRED_VALID_PROPERTY_KEYS + OPTIONAL_VALID_PROPERTY_KEYS
  VALID_TYPE_CLASSES = [
    "SchemaPropertyFieldArray",
    "SchemaPropertyFieldBoolean",
    "SchemaPropertyFieldNumber",
    "SchemaPropertyFieldObject",
    "SchemaPropertyFieldString",
  ].freeze
  FIELD_DETAILS_CLASS_MAPPINGS = {
    "SchemaPropertyFieldArray"   => SchemaSerializer::ArrayDetails,
    "SchemaPropertyFieldBoolean" => SchemaSerializer::BooleanDetails,
    "SchemaPropertyFieldNumber"  => SchemaSerializer::NumberDetails,
    "SchemaPropertyFieldObject"  => SchemaSerializer::ObjectDetails,
    "SchemaPropertyFieldString"  => SchemaSerializer::StringDetails,
  }.freeze

  attr_accessor :properties, :all_of

  validates :properties, presence: true

  validate :properties_field, if: -> { properties.present? }
  validate :all_of_field,     if: -> { all_of.present? }

  def to_schema_property
    return unless valid?
    @required = []
    {
      "properties"  => build_properties,
      "allOf"       => build_all_of,
      "required"    => @required,
    }.compact
  end

  private
    def load_klass(property)
      klass = property["type"].constantize.new(property["class_attributes"])
      klass.field_details = FIELD_DETAILS_CLASS_MAPPINGS[property["type"]].new(property["field_details"]) if property["field_details"].present?
      klass
    end

    def build_properties
      return unless valid?
      properties.each_with_object({}) do |property, obj|
        klass = load_klass(property)
        @required << klass.name if klass.required
        obj.merge!(klass.to_schema_property_obj)
      end
    end

    def build_all_of
      return unless self.all_of.present?
      self.all_of.map do |property|
        klass = "SchemaSerializer::#{property["type"]}".constantize.new(property["class_attributes"])
        klass.to_schema_property
      end
    end

    def validate_property_keys(property)
      # check required keys present
      REQUIRED_VALID_PROPERTY_KEYS.each { |k| errors.add(:properties, "#{k} is a required property") if property.keys.exclude?(k) }
      # check only permitted keys present
      property.keys.each { |k| errors.add(:properties, "#{k} is not a permitted property") if VALID_PROPERTY_KEYS.exclude?(k) }
    end

    def validate_property_type(property)
      unless VALID_TYPE_CLASSES.include?(property["type"])
        errors.add(:properties, "#{property["type"]} is not a valid type class")
      end
    end

    def validate_property_class_attributes(property)
      if property["class_attributes"].present?
        klass = property["type"].constantize.new(property["class_attributes"])
        unless klass.valid?
          error_messages = klass.errors.messages.filter { |k, v| k != :validation_schema }
          error_messages.each { |k, v| errors.add(k, v&.first) }
        end
      else
        errors.add(:properties_class_attributes, "#{property["type"]} is missing required class_attributes")
      end
    end

    def validate_property_field_details(property)
      if property["field_details"].present?
        klass = FIELD_DETAILS_CLASS_MAPPINGS[property["type"]].new(property["field_details"])
        unless klass.valid?
          klass.errors.messages.each { |k, v| errors.add(k, v&.first) }
        end
      end
    end

    def validate_hash_array(items, attribute)
      if items.is_a?(Array)
        classes = items.collect(&:class).uniq
        if classes.length > 1 || classes[0] != Hash
          errors.add(attribute, "Wrong type, expected Array<Hash>")
        end
      else
        errors.add(attribute, "Wrong type, expected Array<Hash>")
      end
    end

    def properties_field
      validate_hash_array(properties, :properties)
      return if errors.size > 0

      properties.each do |property|
        validate_property_keys(property)
        return if errors.size > 0
        validate_property_type(property)
        return if errors.size > 0
        validate_property_class_attributes(property)
        return if errors.size > 0
        validate_property_field_details(property)
      end
    end

    def all_of_field
      if properties.present?
        klass = SchemaSerializer::AllOfDetails.new(properties: all_of)
        unless klass.valid?
          klass.errors.messages.each { |k, v| errors.add(k, v&.first) }
        end
      else
        errors.add(:properties, "Properties attribute is required if utilizing all_of attribute")
      end
    end
end
