# frozen_string_literal: true

=begin
**PARAMS**
  property_name: property string name to check against
  property_const: string or boolean
  then_required: array of property names
  **optional**
  else_required: array of property names

  => SchemaSerializer::IfThenRequiredDetails.new(property_name: "resident",property_const: true, then_required: ["currentResident"], else_required: ["nonResident"])
  => {
        "if": { "properties": { "resident": { "const": true } } },
        "then": { "required": ["currentResident"] },
        "else": { "required": ["nonResident"] }
      }
=end

class SchemaSerializer::IfThenRequiredDetails
  include ActiveModel::Validations
  include Serializable

  attr_accessor :property_name, :property_const, :then_required, :else_required

  validates :property_name, presence: true
  validates :property_const, presence: true
  validates :then_required, presence: true

  validate :property_name_attribute
  validate :property_const_attribute
  validate :then_required_attribute
  validate :else_required_attribute, if: -> { else_required.present? }

  def to_schema_property
    return unless valid?
    {
      "if" => {
        "properties" => { property_name => { "const" => property_const } }
      },
      "then" => { "required" => then_required },
    }.merge(build_else_block)
  end

  private
    def build_else_block
      return {} if else_required.nil?
      { "else" => { "required" => else_required } }
    end

    def property_name_attribute
      unless property_name.is_a?(String)
        errors.add(:property_name, "Wrong type, expected String")
      end
    end

    def property_const_attribute
      unless property_const.is_a?(String) || property_const.is_a?(Integer) || property_const.is_a?(TrueClass) || property_const.is_a?(FalseClass)
        errors.add(:property_const, "Wrong type, expected String, Integer or Boolean")
      end
    end

    def validated_string_array_type(attribute, value)
      if value.is_a?(Array)
        classes = value.collect(&:class).uniq
        if classes.length > 1 || classes[0] != String
          errors.add(:attribute, "Wrong type, expected Array<String>")
        end
      else
        errors.add(:attribute, "Wrong type, expected Array<String>")
      end
    end

    def then_required_attribute
      validated_string_array_type(:then_required, then_required)
    end

    def else_required_attribute
      validated_string_array_type(:else_required, else_required)
    end
end
