require "set"

module Anonymizable
  class ConfigurationError < ArgumentError; end

  class Configuration
    attr_reader :guard,
                :attrs_to_nullify,
                :attrs_to_anonymize,
                :associations_to_anonymize,
                :associations_to_delete,
                :associations_to_destroy,
                :post_anonymization_callbacks

    def initialize(klass)
      @klass = klass
      @guard = nil
      @attrs_to_nullify = Set.new
      @attrs_to_anonymize = Hash.new
      @associations_to_anonymize = Set.new
      @associations_to_delete = Set.new
      @associations_to_destroy = Set.new
      @post_anonymization_callbacks = Set.new
      @public = false
      @raise_on_delete = false
    end

    def only_if(callback)
      validate_callback(callback)

      @guard = callback
    end

    def attributes(*attrs)
      @attrs_to_anonymize.merge! attrs.extract_options!

      attrs.each do |attr|
        validate_attribute(attr)
      end

      @attrs_to_nullify += attrs
    end

    def associations(*associations, &block)
      instance_eval(&block)
    end

    def after(*callbacks)
      callbacks.each do |callback|
        validate_callback(callback)
      end

      @post_anonymization_callbacks += callbacks
    end

    def public?
      @public
    end

    def raise_on_delete?
      @raise_on_delete
    end

    private

    def public
      @public = true
    end

    def raise_on_delete
      @raise_on_delete = true
    end

    def anonymize(*associations)
      @associations_to_anonymize += associations
    end

    def delete(*associations)
      @associations_to_delete += associations
    end

    def destroy(*associations)
      @associations_to_destroy += associations
    end

    def validate_callback(callback)
      if !callback.respond_to?(:call) && !callback.is_a?(String) && !callback.is_a?(Symbol)
        raise ConfigurationError.new(
          "Expected #{callback} to respond to 'call' or be a string or symbol."
        )
      end
    end

    def validate_attribute(attr)
      if !@klass.attribute_names.include?(attr.to_s)
        raise ConfigurationError.new("Nonexitent attribute #{attr} on #{@klass}.")
      end
    end
  end
end
