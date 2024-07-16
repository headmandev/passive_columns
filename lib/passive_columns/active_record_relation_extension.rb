# frozen_string_literal: true

module PassiveColumns
  # ActiveRecordRelationExtension is a module that extends ActiveRecord::Relation
  # to automatically select all columns except passive columns if no columns are selected.
  module ActiveRecordRelationExtension
    if ActiveRecord::VERSION::MAJOR >= 7
      def exec_main_query(...)
        if klass.try(:_passive_columns).present? && select_values.blank?
          self.select_values = klass.column_names - klass._passive_columns
        end
        super
      end
    else
      def exec_queries(...)
        if klass.try(:_passive_columns).present? && select_values.blank?
          self.select_values = klass.column_names - klass._passive_columns
        end
        super
      end
    end

    def to_sql
      return @to_sql unless @to_sql.nil?

      # @see ActiveRecord::QueryMethods::assert_mutability!
      return super if @loaded || (defined?(@arel) && @arel)

      if klass.try(:_passive_columns).present? && select_values.blank?
        self.select_values = klass.column_names - klass._passive_columns
      end

      super
    end
  end
end
