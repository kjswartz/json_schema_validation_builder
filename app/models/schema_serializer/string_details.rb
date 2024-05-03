# frozen_string_literal: true

class SchemaSerializer::StringDetails
  include ActiveModel::Validations
  include Serializable

  VALID_FORMATS = ["date", "date-time", "email", "uri"].freeze

  attr_accessor :pattern, :const, :enum, :format, :min_length, :max_length

  validates :min_length, numericality: true, allow_blank: true
  validates :max_length, numericality: true, allow_blank: true
  validates :format, inclusion: { in: VALID_FORMATS, allow_blank: true, message: "Format type is not supported" }

  validate :string_attributes
  validate :max_length_property, if: -> { max_length.present? }
  validate :min_length_property, if: -> { min_length.present? }
  validate :enum_property,       if: -> { enum.present? }

  def to_schema_property
    return unless valid?
    {
      "const"      => const,
      "format"     => format,
      "enum"       => enum,
      "pattern"    => pattern,
      "minLength"  => min_length.present? ? min_length.to_i : nil,
      "maxLength"  => max_length.present? ? max_length.to_i : nil,
    }.compact
  end

  private
    def validate_is_string_type(attribute, value)
      unless value.is_a?(String)
        errors.add(attribute, "Wrong type, expected String")
      end
    end

    def string_attributes
      validate_is_string_type(:pattern, pattern) if pattern.present?
      validate_is_string_type(:const, const) if const.present?
    end

    def max_length_property
      if min_length && max_length.to_i < min_length.to_i
        errors.add(:max_length, "max_length cannot be less than min_length")
      end
    end

    def min_length_property
      if max_length && max_length.to_i < min_length.to_i
        errors.add(:min_length, "min_length cannot be greater than max_length")
      end
    end

    def enum_property
      if enum.is_a?(Array)
        classes = enum.collect(&:class).uniq
        if classes.length > 1 || classes[0] != String
          errors.add(:enum, "Wrong type, expected Array<String>")
        end
      else
        errors.add(:enum, "Wrong type, expected Array<String>")
      end
    end
end
