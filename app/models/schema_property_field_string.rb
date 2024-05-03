# frozen_string_literal: true

class SchemaPropertyFieldString < SchemaPropertyField
  serialize :field_details, SchemaSerializer::StringDetails
end
