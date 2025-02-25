# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :projects
  has_many :projects_with_passive_description, class_name: 'ProjectWithPassiveDescription'

  belongs_to :default_project, class_name: 'Project', optional: true, inverse_of: :user

  accepts_nested_attributes_for :projects
end
