# frozen_string_literal: true

require 'passive_columns/active_record_relation_extension'
require 'passive_columns/active_record_association_builder_extension'

module PassiveColumns # :nodoc:
  class Railtie < Rails::Railtie # :nodoc:
    config.to_prepare do |_app|
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Relation.prepend ActiveRecordRelationExtension
        ActiveRecord::Associations::Builder::Association.prepend ActiveRecordAssociationBuilderExtension
      end
    end
  end
end
