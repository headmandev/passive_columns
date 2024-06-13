# frozen_string_literal: true

class Project < ActiveRecord::Base
  include PassiveColumns

  passive_columns :guidelines, :description

  belongs_to :user
end
