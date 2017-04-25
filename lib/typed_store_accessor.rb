require "active_support/all"
require "active_record"
require "typed_store_accessor/version"
require "typed_store_accessor/time_helpers"

module TypedStoreAccessor
  extend ActiveSupport::Concern
  include TimeHelpers

  class_methods do
    def _typed_store_accessor_module
      @_typed_store_accessor_module ||=
        begin
          mod = Module.new
          include mod
          mod
        end
    end
    def typed_store_accessor(store, prop_type, prop, default=nil, opts={})
      default = [] if default.nil? && prop_type == :array
      _typed_store_accessor_module.module_eval do
        define_method(prop) do
          self.send(:write_attribute, store, {}) if self.send(:read_attribute,store).nil?
          value = self.send(:read_attribute, store)[prop.to_s]
          if value.nil?
            if !default.nil?
              value = case default
                      when Hash
                        default.dup
                      else
                        default
                      end
              self.send("#{prop}=",value)
            end
            return value
          end
          case prop_type
          when :big_decimal
            value = BigDecimal.new(value)
          when :string
            value.to_s
          when :time
            if value.is_a?(Time)
              value
            else
              value.blank? ? nil : parse_time(value)
            end
          else
            value
          end
        end

        define_method("#{prop}=") do |value|
          self.send(:write_attribute, store, {}) if self.send(:read_attribute,store).nil?
          value_for_storage =
            case prop_type
            when :boolean
              ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
            when :non_blank_string
              value == '' ? nil : value
            when :restricted_string
              raise "no values provided" unless opts[:values].present?
              if opts[:values].include?(value)
                value
              else
                raise "Value not one of the following: #{opts[:values].join(" ")}"
              end
            when :string
              value.blank? ? nil : value.to_s
            when :integer
              value.blank? ? nil : value.to_i
            when :float
              value.blank? ? nil : value.to_f
            when :big_decimal
              value.blank? ? nil : value.to_d
            when :time
              if value.is_a?(Time)
                value
              else
                value.blank? ? nil : parse_time(value)
              end
            when :array
              value = value.nil? ? default : value
              raise 'Value is not an array' unless value.kind_of? Array
              value
            when :hash
              value = value.nil? ? default : value
              if value.is_a?(String)
                begin
                  value = JSON.parse(value)
                rescue JSON::ParserError
                end
              end
              raise 'Value is not a hash' unless value.kind_of? Hash
              value
            else
              raise "Invalid prop type #{prop_type.to_s}"
            end

          self.send(:read_attribute,store)[prop.to_s] = value_for_storage
        end

        if prop_type == :boolean
          define_method("#{prop}?") do
            !!send(prop)
          end
        end
      end
    end
  end
end
