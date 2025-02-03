# frozen_string_literal: true

class EmailItem < ApplicationRecord
  # belongs_to :item, polymorphic: true, optional: false
  belongs_to :item, polymorphic: true, optional: false
  belongs_to :email, optional: false
end
