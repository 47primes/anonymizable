require 'set'

module Anonymizable
  class ConfigurationError < ArgumentError; end

  class Configuration

    attr_reader :guard,
                :attrs_to_nullify,
                :attrs_to_anonymize,
                :associations_to_anonymize,
                :post_anonymization_callbacks

    def initialize(klass)
      @klass                        = klass
      @guard                        = nil
      @attrs_to_nullify             = Set.new
      @attrs_to_anonymize           = Hash.new
      @associations_to_anonymize    = Set.new
      @post_anonymization_callbacks = Set.new
      @public                       = false
    end

    def only_if(callback)
      validate_callback(callback)

      @guard = callback
    end

    def nullify(*attributes)
      attributes.each do |attr|
        validate_attribute(attr)
      end

      @attrs_to_nullify += attributes
    end

    def anonymize(attr, callback)
      validate_callback(callback)

      @attrs_to_anonymize[attr] = callback
    end

    def associations(*associations)
      @associations_to_anonymize += associations
    end

    def after(*callbacks)
      callbacks.each do |callback|
        validate_callback(callback)
      end

      @post_anonymization_callbacks += callbacks
    end

    def public(boolean)
      raise ConfigurationError.new("boolean expected") if !boolean.is_a?(TrueClass) && !boolean.is_a?(FalseClass)
      @public = boolean
    end

    def public?
      @public
    end

    private

      def validate_callback(callback)
        if !callback.respond_to?(:call) && !callback.is_a?(String) && !callback.is_a?(Symbol)
          raise ConfigurationError.new("Expected #{callback} to respond to 'call' or be a string or symbol.\n#{caller.join("\n")}")
        end
      end

      def validate_attribute(attr)
        if !@klass.attribute_names.include?(attr.to_s)
          raise ConfigurationError.new("Nonexitent attribute #{attr} on #{@klass}.")
        end
      end

  end
end