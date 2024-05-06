# frozen_string_literal: true

class SchemaPropertyFieldArray < SchemaPropertyField
  serialize :field_details, SchemaSerializer::ArrayDetails
end
