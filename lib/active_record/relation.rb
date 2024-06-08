# frozen_string_literal: true

require "active_record"
require "passive_columns/active_record_relation_extension"

ActiveRecord::Relation.prepend PassiveColumns::ActiveRecordRelationExtension
