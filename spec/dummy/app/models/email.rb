# frozen_string_literal: true
#
class Email < ApplicationRecord
  include PassiveColumns
  # passive_columns :mail

  has_many :email_items, dependent: :destroy
  accepts_nested_attributes_for :email_items

  validates :from, presence: true
end