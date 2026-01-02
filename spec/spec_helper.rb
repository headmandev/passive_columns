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

  config.around(:each) do |example|
    ActiveRecord::Base.connection.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

load "#{Rails.root}/db/schema.rb"
