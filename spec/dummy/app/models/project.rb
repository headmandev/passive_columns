# frozen_string_literal: true

class Project < ActiveRecord::Base
  include PassiveColumns

  belongs_to :user

  passive_columns :guidelines, :description

  validates :name, presence: true

  validates :description, presence: true
  # Under the hood, the above line is equivalent to:
  # validates :description, presence: true, if: -> { attributes.key?('description') }
end
