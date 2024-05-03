# frozen_string_literal: true

class SchemaSerializer::BooleanDetails
  include ActiveModel::Validations
  include Serializable

  attr_accessor :const

  validates :const, inclusion: { in: [true, false], allow_blank: true, message: "Expected TrueClass or FalseClass type" }

  def to_schema_property
    return unless valid?
    {
      "const"  => const,
    }.compact
  end
end
