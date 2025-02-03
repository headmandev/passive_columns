# frozen_string_literal: true

ActiveRecord::Type.register(:project_settings_type, ProjectSettingsType)

class Project < ActiveRecord::Base
  include PassiveColumns
  passive_columns :guidelines, :description, :settings

  belongs_to :user
  has_many :project_items, dependent: :destroy

  accepts_nested_attributes_for :project_items

  attribute :settings, :project_settings_type, default: '{"color": "purple"}'

  validates :name, presence: true

  validates :settings, presence: true
  # Under the hood, the above line is equivalent to:
  # validates :settings, presence: true, if: -> { attributes.key?('settings') }
  validates :description, presence: true
  # Under the hood, the above line is equivalent to:
  # validates :description, presence: true, if: -> { attributes.key?('description') }
end
