# frozen_string_literal: true

module PassiveColumns
  # ActiveRecordRelationExtension is a module that extends ActiveRecord::Relation
  # to automatically select all columns except passive columns if no columns are selected.
  module ActiveRecordRelationExtension
    if ActiveRecord::VERSION::MAJOR >= 7
      def exec_main_query(...)
        PassiveColumns.apply_select_scope_to(self)
        super
      end
    else
      def exec_queries(...)
        PassiveColumns.apply_select_scope_to(self)
        super
      end
    end

    def to_sql
      return @to_sql unless @to_sql.nil?

      # @see ActiveRecord::QueryMethods::assert_mutability!
      return super if @loaded || (defined?(@arel) && @arel)

      PassiveColumns.apply_select_scope_to(self)
      super
    end
  end
end
