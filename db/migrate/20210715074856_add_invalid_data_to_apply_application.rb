# frozen_string_literal: true

class AddInvalidDataToApplyApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :apply_applications, :invalid_data, :jsonb
  end
end
