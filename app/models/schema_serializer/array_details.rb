# frozen_string_literal: true
=begin
**NOTES**
  Base Array schema property type used to build JSON Schema Draft 2020-12 version
  https://json-schema.org/understanding-json-schema/reference/array.html
**PARAMS**
  min_items/max_items: number of min/max items allowed
  unique_items: boolean
  item: Is an object of the array of things you wish to collect. 
         It works like the object serializer where you pass in a PropertyType of 
         what you are collecting.
  {
    type: inclusion in SchemaPropertyField types
    class_attributes: validated against SchemaPropertyField model minus validation_schema relationship
    field_details?: validated against SchemaPropertyField type field_details serializer
  }
**Example**
  ArrayPropertyField.new(
    name: "address",
    title: "Address",
    description: "Enter your last 3 addresses",
    field_details: SchemaSerializer::ArrayDetails.new(min_items: 1, max_items: 3,
      item: {
        type: "SchemaPropertyFieldObject",
        class_attributes: { name: "address", description: "Adress", title: "Enter Address" },
        field_details: {
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
          ]
        }
      }
    )
  )
=end

class SchemaSerializer::ArrayDetails
  include ActiveModel::Validations
  include Serializable

  attr_accessor :min_items, :max_items, :unique_items, :item

  validates :min_items, numericality: true, allow_blank: true
  validates :max_items, numericality: true, allow_blank: true
  validates :unique_items, inclusion: { in: [true, false], allow_blank: true, message: "Expected TrueClass or FalseClass type" }
  validates :item, presence: true

  validate :max_items_property, if: -> { max_items.present? }
  validate :min_items_property, if: -> { min_items.present? }
  validate :item_field,         if: -> { item.present? }

  REQUIRED_VALID_PROPERTY_KEYS = ["type", "class_attributes"].freeze
  OPTIONAL_VALID_PROPERTY_KEYS = ["field_details"].freeze
  VALID_PROPERTY_KEYS = REQUIRED_VALID_PROPERTY_KEYS + OPTIONAL_VALID_PROPERTY_KEYS
  VALID_TYPE_CLASSES = [
    "SchemaPropertyFieldBoolean",
    "SchemaPropertyFieldNumber",
    "SchemaPropertyFieldObject",
    "SchemaPropertyFieldString",
  ].freeze
  FIELD_DETAILS_CLASS_MAPPINGS = {
    "SchemaPropertyFieldBoolean" => SchemaSerializer::BooleanDetails,
    "SchemaPropertyFieldNumber"  => SchemaSerializer::NumberDetails,
    "SchemaPropertyFieldObject"  => SchemaSerializer::ObjectDetails,
    "SchemaPropertyFieldString"  => SchemaSerializer::StringDetails,
  }.freeze

  def to_schema_property
    return unless valid?
    {
      "minItems"    => min_items.present? ? min_items.to_i : nil,
      "maxItems"    => max_items.present? ? max_items.to_i : nil,
      "uniqueItems" => unique_items,
      "items"       => build_item,
    }.compact
  end

  private
    def max_items_property
      if min_items && max_items.to_i < min_items.to_i
        errors.add(:max_items, "max_items cannot be less than min_items")
      end
    end

    def min_items_property
      if max_items && max_items.to_i < min_items.to_i
        errors.add(:min_items, "min_items cannot be greater than max_items")
      end
    end

    def validate_item_keys(item)
      # check required keys present
      REQUIRED_VALID_PROPERTY_KEYS.each { |k| errors.add(:item, "#{k} is a required property") if item.keys.exclude?(k) }
      # check only permitted keys present
      item.keys.each { |k| errors.add(:item, "#{k} is not a permitted property") if VALID_PROPERTY_KEYS.exclude?(k) }
    end

    def validate_item_type(item)
      unless VALID_TYPE_CLASSES.include?(item["type"])
        errors.add(:item, "#{item["type"]} is not a valid type class")
      end
    end

    def validate_item_class_attributes(item)
      if item["class_attributes"].present?
        klass = item["type"].constantize.new(item["class_attributes"])
        unless klass.valid?
          error_messages = klass.errors.messages.filter { |k, v| k != :validation_schema }
          error_messages.each { |k, v| errors.add(k, v&.first) }
        end
      else
        errors.add(:item_class_attributes, "#{item["type"]} is missing required class_attributes")
      end
    end

    def validate_item_field_details(item)
      if item["field_details"].present?
        klass = FIELD_DETAILS_CLASS_MAPPINGS[item["type"]].new(item["field_details"])
        unless klass.valid?
          klass.errors.messages.each { |k, v| errors.add(k, v&.first) }
        end
      end
    end

    def item_field
      validate_item_keys(item)
      return if errors.size > 0
      validate_item_type(item)
      return if errors.size > 0
      validate_item_class_attributes(item)
      return if errors.size > 0
      validate_item_field_details(item)
    end

    def load_klass(item)
      klass = item["type"].constantize.new(item["class_attributes"])
      klass.field_details = FIELD_DETAILS_CLASS_MAPPINGS[item["type"]].new(item["field_details"]) if item["field_details"].present?
      klass
    end

    def build_item
      return unless valid?
      klass = load_klass(item)
      klass.to_schema_property
    end
end
