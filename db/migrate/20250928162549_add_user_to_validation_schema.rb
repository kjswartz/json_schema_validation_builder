class AddUserToValidationSchema < ActiveRecord::Migration[7.1]
  def change
    add_reference :validation_schemas, :user, null: false, foreign_key: true
  end
end
