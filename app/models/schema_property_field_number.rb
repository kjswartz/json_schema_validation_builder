# frozen_string_literal: true

class SchemaPropertyFieldNumber < SchemaPropertyField
  serialize :field_details, SchemaSerializer::NumberDetails
end
