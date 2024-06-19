# frozen_string_literal: true

require 'passive_columns/railtie' if defined?(Rails::Railtie)
require 'passive_columns/loader'

# PassiveColumns module is the module
# that allows you to skip retrieving the column values from the database by default.
# The columns are retrieved only when they are called.
# This module is useful when you have a model with a lot of columns
# and you don't want to retrieve all of them at once.
#
#  class Page < ApplicationRecord
#    include PassiveColumns
#    passive_columns :huge_article
#  end
#
# By default it retrieves all the columns except the passive ones.
#
#  article = Page.where(status: :active).to_a
#  # => SELECT "pages"."id", "pages"."status", "pages"."title" FROM "pages" WHERE "pages"."status" = 'active'
#
# If you specify the columns via select it retrieves only the specified columns and nothing more.
#
#  page = Page.select(:id, :title).take # => #<Page id: 1, title: "Some title">
#  page.to_json # => {"id": 1, "title": "Some title"}
#
# But you still has an ability to retrieve the passive column on demand
#
#  page.huge_article
#  # => SELECT "pages"."huge_article" WHERE "pages"."id" = 1 LIMIT 1
#  # => 'Some huge article...'
#  page.to_json # => {"id": 1, "title": "Some title", "huge_article": "Some huge article..."}
#
# The next time you call the passive column it won't hit the database as it is already loaded.
#  page.huge_article # => 'Some huge article...'
module PassiveColumns
  extend ActiveSupport::Concern

  included do
    class_attribute :_passive_columns, default: []
  end

  class_methods do
    # Specify column names for on-demand loading.
    # While the columns aren't actively loading, they are still responsive and load when called upon.
    #  passive_columns :huge_article, :settings
    # @param [Array<Symbol>] columns
    # @return [void]
    def passive_columns(*columns)
      self._passive_columns = columns.map(&:to_s)
      columns.each do |column|
        define_method(column) { _passive_column_loader.load(column) { super() } }
        define_method(:"#{column}=") do |value|
          _passive_column_loader.load(column)
          super(value)
        end
      end
    end

    # Each validation rule directly associated with a passive column
    # has an "if: -> {..}" added by default to skip validation if the column is not set.
    #  passive_columns :huge_article
    #  validates :huge_article, presence: true
    #
    # The above code converts the validation rule into a rule with IF under the hood.
    # and will be equivalent:
    #  passive_columns :huge_article
    #  validates :huge_article, presence: true, if: -> { attributes.key?('huge_article') }
    #
    # Another example with a condition:
    #  passive_columns :huge_article
    #  validates :huge_article, presence: true, if: -> { status == 'active' }
    #
    # The above code will be equivalent to the below under the hood:
    #  passive_columns :huge_article
    #  validates :huge_article, presence: true, if: -> { attributes.key?('huge_article') && status == 'active' }
    #
    # !! A validation rule will not be converted if the rule has been set for many attributes.
    #  passive_columns :huge_article
    #  validates :huge_article, :settings, presence: true
    # The code above won't be transformed under the hood and the "if" condition won't be added.
    # It is important to set the validation rule for each "passive column" separately.
    # Otherwise, the passive column will be retrieved from DB before validation itself.
    def set_callback(name, *filter_list, &block)
      opts = filter_list.extract_options!
      if name == :validate && opts[:attributes]&.one?
        passive_column = opts[:attributes].map(&:to_s) & _passive_columns
        opts[:if] = ([-> { attributes.key?(passive_column.first) }] + Array(opts[:if])) if passive_column.present?
      end
      super(name, *filter_list, opts, &block)
    end
  end

  # This method loads a column value, if not already loaded, from the database
  # regardless of whether the column is added to "passive_columns" or not.
  #
  # It uses the Rails' ".pick" method to get the value of the column under the hood
  #  user = User.select('id').take!
  #  user.load_column(:name) # => SELECT "name" FROM "users" WHERE "id" = ? LIMIT ?
  #  'John'
  #  user.load_column(:name)
  #  'John'
  # @param [Symbol, String] column
  # @return [any]
  def load_column(column)
    _passive_column_loader.load(column, force: true)
  end

  def _passive_column_loader
    @_passive_column_loader ||= PassiveColumns::Loader.new(self, _passive_columns)
  end
end
