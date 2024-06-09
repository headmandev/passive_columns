# frozen_string_literal: true

class Project < ActiveRecord::Base
  include PassiveColumns

  belongs_to :user
end