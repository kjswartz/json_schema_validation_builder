# frozen_string_literal: true

class SchemaPropertyFieldObject < SchemaPropertyField
  serialize :field_details, SchemaSerializer::ObjectDetails
end
