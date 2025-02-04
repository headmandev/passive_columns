# frozen_string_literal: true

require_relative 'boot'

require 'logger'
require 'rails'
require 'action_controller/railtie'
require 'active_record/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    # config.logger = Logger.new("/dev/null")
    config.eager_load = false
  end
end
