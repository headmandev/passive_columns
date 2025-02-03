# frozen_string_literal: true

module PassiveColumns
  # This module is used to extend the ActiveRecord::Associations::Builder::Association class
  # to add a proc with default scope to the association if there is no proc defined.
  module ActiveRecordAssociationBuilderExtension
    extend ActiveSupport::Concern

    class_methods do
      # def create_reflection(*)
      #   super.tap do |res|
      #     next if res.polymorphic?
      #     next unless _klass_has_passive_columns(res) && res.scope.nil?
      #
      #     default_relation = -> { unscoped }
      #     res.instance_variable_set(:@scope, proc { instance_exec(&default_relation) })
      #   end
      # end

      # Check if the association class has passive columns
      # @param [ActiveRecord::Reflection::AssociationReflection] res
      def _klass_has_passive_columns(res)
        res.klass.respond_to?(:_passive_columns)
      rescue NameError
        # If +config.eager_load!+ is disabled, an association class may not be loaded yet
        # so we can't constantize to check if the class has passive columns.
        # In this case, we assume the class has passive columns.
        true
      end
    end
  end
end
