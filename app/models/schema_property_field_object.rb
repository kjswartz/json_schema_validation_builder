# frozen_string_literal: true

class SchemaPropertyFieldObject < SchemaPropertyField
  serialize :field_details, coder: SchemaSerializer::ObjectDetails
end
