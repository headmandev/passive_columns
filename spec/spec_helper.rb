# frozen_string_literal: true

require_relative 'dummy/config/environment'

require 'active_support'
require 'active_record'
require 'passive_columns'

ENV['RAILS_ENV'] = 'test'

RSpec.configure do |config|
  config.order = :random
  config.formatter = :documentation
  config.color = true
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

load "#{Rails.root}/db/schema.rb"

# def build_custom_product_class(&block)
#   klass = Class.new(Product) do
#     def self.model_name
#       ActiveModel::Name.new(self, nil, "product")
#     end
#   end
#
#   klass.instance_eval(&block)
#
#   klass
# end
