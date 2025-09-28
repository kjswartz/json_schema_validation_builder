# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
    subject { described_class.new(email: "test@example.com", password: "password") }

    describe "validations" do
        it { should validate_presence_of(:email) }
        it { should validate_presence_of(:password) }
        it { should validate_length_of(:password).is_at_least(6) }
    end
end