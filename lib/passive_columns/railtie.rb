# frozen_string_literal: true

require 'passive_columns/active_record_relation_extension'

module PassiveColumns # :nodoc:
  class Railtie < Rails::Railtie # :nodoc:
    config.to_prepare do |_app|
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Relation.prepend(ActiveRecordRelationExtension)
      end
    end
  end
end
