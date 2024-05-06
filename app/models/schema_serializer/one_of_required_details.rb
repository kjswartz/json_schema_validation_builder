# frozen_string_literal: true

=begin
**PARAMS**
  required_properties: array of string property names

  takes as many arrays you want. each array is a required properties list
  ["x"], ["y"]
  ["x"], ["y","z"]
  ["x"], ["q","y","z"], ["a","b"]

  => SchemaSerializer::OneOfRequiredDetails.new(required_properties: [["x"],["q","y","z"], ["a","b"]])
  => {"oneOf"=>[{"required"=>["x"]}, {"required"=>["q", "y", "z"]}, {"required"=>["a", "b"]}]}
=end

class SchemaSerializer::OneOfRequiredDetails
  include ActiveModel::Validations
  include Serializable

  attr_accessor :required_properties

  validates :required_properties, presence: true

  validate :required_properties_attribute

  def to_schema_property
    return unless valid?
    {
      "oneOf" => required_properties.map { |p| { "required" => p } }
    }
  end

  private
    def required_properties_attribute
      if required_properties.is_a?(Array)
        classes = required_properties.collect(&:class).uniq
        if classes.length > 1 || classes[0] != Array
          errors.add(:required_properties, "Wrong type, expected Array<Array<String>>")
        else
          required_properties.each do |p|
            property_classes = p.collect(&:class).uniq
            if property_classes.length > 1 || property_classes[0] != String
              errors.add(:required_properties, "Wrong type, expected Array<Array<String>>")
            end
          end
        end
      else
        errors.add(:required_properties, "Wrong type, expected Array<Array<String>>")
      end
    end
end
