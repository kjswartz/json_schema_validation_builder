class SchemaPropertyField < ApplicationRecord
  belongs_to :validation_schema

  validates :name, presence: true
  validate :field_detail_properties, if: -> { field_details.present? }

  def to_schema_property
    get_property_details.merge(field_details_schema_property).compact
  end

  def to_schema_property_obj
    { name => to_schema_property }
  end

  private
  def field_details_schema_property
    if get_schema_type == "object"
      field_details&.to_schema_property || {}
    else
      field_details&.to_schema_property || {}
    end
  end

  def get_property_details
    {
      "description" => description,
      "title"       => title,
      "type"        => get_schema_type
    }.compact
  end

  def field_detail_properties
    unless field_details.valid?
      errors.add(:field_details, field_details.errors)
    end
  end

  def get_schema_type
    case type
    when "SchemaPropertyFieldArray"
      "array"
    when "SchemaPropertyFieldBoolean"
      "boolean"
    when "SchemaPropertyFieldNumber"
      "number"
    when "SchemaPropertyFieldObject"
      "object"
    when "SchemaPropertyFieldString"
      "string"
    else
      nil
    end
  end
end
