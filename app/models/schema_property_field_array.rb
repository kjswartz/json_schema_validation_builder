# frozen_string_literal: true

class SchemaPropertyFieldArray < SchemaPropertyField
  serialize :field_details, coder: SchemaSerializer::ArrayDetails
end
