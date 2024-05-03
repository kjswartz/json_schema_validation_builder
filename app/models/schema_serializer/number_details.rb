# frozen_string_literal: true

class SchemaSerializer::NumberDetails
  include ActiveModel::Validations
  include Serializable

  attr_accessor :min_value, :max_value

  validates :min_value, numericality: true, allow_blank: true
  validates :max_value, numericality: true, allow_blank: true

  validate :max_value_property, if: -> { max_value.present? }
  validate :min_value_property, if: -> { min_value.present? }

  def to_schema_property
    return unless valid?
    {
      "minValue"  => min_value.present? ? min_value.to_i : nil,
      "maxValue"  => max_value.present? ? max_value.to_i : nil,
    }.compact
  end

  private
    def max_value_property
      if min_value && max_value.to_i < min_value.to_i
        errors.add(:max_value, "max_value cannot be less than min_value")
      end
    end

    def min_value_property
      if max_value && max_value.to_i < min_value.to_i
        errors.add(:min_value, "min_value cannot be greater than max_value")
      end
    end
end
