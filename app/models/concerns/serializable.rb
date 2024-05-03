# frozen_string_literal: true

module Serializable
  extend ActiveSupport::Concern
  IGNORE_FIELDS = ["validation_context", "errors"]

  def initialize(json)
    unless json.blank?
      if json.is_a?(String)
        json = JSON.parse(json)
      end
      # Will only set the properties that have an accessor,
      # such as those provided to an attr_accessor call.
      json.to_hash.each { |k, v| self.public_send("#{k}=", v) unless IGNORE_FIELDS.include?(k) }
    end
  end

  class_methods do
    def load(json)
      return nil if json.blank?
      self.new(json)
    end

    def dump(obj)
      if obj.is_a?(self)
        obj.to_json
      else
        raise StandardError, "Expected #{self}, got #{obj.class}"
      end
    end
  end
end
