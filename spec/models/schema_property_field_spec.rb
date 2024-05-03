require 'rails_helper'

RSpec.describe SchemaPropertyField, type: :model do
  describe 'associations' do
    it { should belong_to(:validation_schema) }
  end
end
