class ValidationSchema < ApplicationRecord
  validates :name, presence: true
  has_many :schema_property_fields

  serialize :all_of, SchemaSerializer::AllOfDetails

  def to_schema_property
    {
      "title"       => title,
      "description" => description,
      "properties"  => get_properties,
      "allOf"       => get_all_of_properties,
      "required"    => get_required_properties,
    }.compact
  end

  private
    def get_properties
      schema_property_fields.map(&:to_schema_property_obj)&.inject(:merge)&.compact
    end

    def get_all_of_properties
      all_of.present? ? all_of.to_schema_property : nil
    end

    def get_required_properties
      required = schema_property_fields.filter(&:required).collect(&:name)
      required.present? ? required : nil
    end
end
