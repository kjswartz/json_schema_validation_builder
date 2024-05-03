# frozen_string_literal: true

class SchemaPropertyFieldBoolean < SchemaPropertyField
  serialize :field_details, SchemaSerializer::BooleanDetails
end
