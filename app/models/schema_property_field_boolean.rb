# frozen_string_literal: true

class SchemaPropertyFieldBoolean < SchemaPropertyField
  serialize :field_details, coder: SchemaSerializer::BooleanDetails
end
