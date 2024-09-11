# frozen_string_literal: true

class SchemaPropertyFieldString < SchemaPropertyField
  serialize :field_details, coder: SchemaSerializer::StringDetails
end
