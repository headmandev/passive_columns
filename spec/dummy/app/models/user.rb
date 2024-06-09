# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :projects
  belongs_to :default_project, class_name: 'Project', optional: true, inverse_of: :user
end