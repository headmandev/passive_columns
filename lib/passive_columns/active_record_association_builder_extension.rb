# frozen_string_literal: true
#
module PassiveColumns
  # This module is used to extend the ActiveRecord::Associations::Builder::Association class
  # to add a proc with default scope to the association if there is no proc defined.
  module ActiveRecordAssociationBuilderExtension
    extend ActiveSupport::Concern

    class_methods do
      def create_reflection(*)
        super.tap do |res|
          next if res.polymorphic?
          next unless res.klass.respond_to?(:_passive_columns) && res.scope.nil?

          default_relation = -> { unscoped }
          res.instance_variable_set(:@scope, proc { instance_exec(&default_relation) })
        end
      end
    end
  end
end
