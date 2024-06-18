# frozen_string_literal: true

module PassiveColumns
  # ActiveRecordRelationExtension is a module that extends ActiveRecord::Relation
  # to automatically select all columns except passive columns if no columns are selected.
  module ActiveRecordRelationExtension
    def exec_main_query(**args)
      _set_columns_except_passive_if_nothing_selected
      super
    end

    def to_sql
      _set_columns_except_passive_if_nothing_selected
      super
    end

    def _set_columns_except_passive_if_nothing_selected
      return nil if klass.try(:_passive_columns).blank? || select_values.any?

      self.select_values = klass.column_names - klass._passive_columns
    end
  end
end
