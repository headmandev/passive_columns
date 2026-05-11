# frozen_string_literal: true

module PassiveColumns
  # Loader is a class helper that loads a column value from the database if it is not loaded yet.
  class Loader
    attr_reader :passive_columns, :model

    # @param [ActiveRecord::Base] model
    # @param [Array<Symbol>] passive_columns
    def initialize(model, passive_columns)
      @model = model
      @passive_columns = passive_columns
    end

    # @param [Symbol, String] column
    # @param [Boolean] force
    # @return [any]
    def load(column, force: false)
      return yield if block_given?

      model.send(column)
    rescue ActiveModel::MissingAttributeError
      materialize_missing_column(column, force)
    end

    private

    def materialize_missing_column(column, force)
      allowed_columns = (force ? [column] : passive_columns).map(&:to_s)
      raise if allowed_columns.exclude?(column.to_s) || identity_constraints.value?(nil)

      log_lazy_sql_load(column)
      value = pick_value(column)
      model[column] = value
      model.send(:clear_attribute_change, column)
      model[column]
    end

    def log_lazy_sql_load(column)
      logger = model.logger
      return unless logger&.debug?

      ctx = identity_constraints.map { |k, v| "#{k}=#{v.inspect}" }.join(', ')
      logger.debug("[passive_columns] On-demand SQL load of #{model.class.name}##{column} (#{ctx})")
    end

    def pick_value(column)
      model.class.unscoped.where(identity_constraints).pick(column)
    end

    if ActiveRecord::VERSION::MAJOR >= 7
      def identity_constraints
        @identity_constraints ||= model.send(:_query_constraints_hash)
      end
    else
      def identity_constraints
        @identity_constraints ||= {
          model.instance_variable_get(:@primary_key) => model.id_in_database
        }
      end
    end
  end
end
