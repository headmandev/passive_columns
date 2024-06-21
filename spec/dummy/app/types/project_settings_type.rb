# frozen_string_literal: true

class ProjectSettingsType < ActiveRecord::Type::Value
  class Settings
    include ActiveModel::Model
    include ActiveModel::Dirty
    attr_accessor :color

    define_attribute_methods :color

    def initialize(val)
      if val.is_a?(Settings)
        super(val.attributes)
      else
        super
      end
    end

    def ==(other)
      return super unless other.is_a?(self.class)

      attributes.all? { |name, value| value == other.attributes[name] }
    end

    def attributes
      { color: color }
    end

    def assign_attributes(new_attributes)
      clear_changes_information
      new_color = new_attributes['color'] || new_attributes[:color]
      color_will_change! if new_color != color
      super
    end
  end

  def type
    :json
  end

  # @return [Settings]
  def cast_value(obj)
    val = case obj
          when String
            JSON.parse(obj)
          else
            obj
          end

    Settings.new(val)
  end

  def serialize(value)
    value.to_json
  end
end
