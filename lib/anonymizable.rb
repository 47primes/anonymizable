require "active_record"
require "anonymizable/configuration"

module Anonymizable
  AnonymizeError = Class.new(StandardError)
  DeleteProhibitedError = Class.new(StandardError)
  DestroyProhibitedError = Class.new(StandardError)

  def self.extended(klass)
    klass.class_eval do
      class << self
        attr_reader :anonymization_config

        def anonymizable(*attrs, &block)
          @anonymization_config ||= Configuration.new(self)
          if block
            options = attrs.extract_options!
            @anonymization_config.send(:public) if options[:public] == true
            @anonymization_config.send(:raise_on_delete) if options[:raise_on_delete] == true
            @anonymization_config.instance_eval(&block)
          else
            @anonymization_config.attributes(*attrs)
          end

          define_method(:anonymize!) do
            return false unless _can_anonymize?

            original_attributes = attributes.dup
            transaction do
              _anonymize_columns
              _anonymize_associations
              _delete_associations
              _destroy_associations
            end
            _perform_post_anonymization_callbacks(original_attributes)
            true
          end

          unless @anonymization_config.public?
            send(:private, :anonymize!)
          end

          if @anonymization_config.raise_on_delete?
            define_method(:delete) do
              raise DeleteProhibitedError.new("delete is prohibited on #{self.class}")
            end

            define_method(:destroy) do
              raise DestroyProhibitedError.new("destroy is prohibited on #{self.class}")
            end
          end
        end
      end

      private

      def _can_anonymize?
        if self.class.anonymization_config.guard
          if self.class.anonymization_config.guard.respond_to?(:call)
            return self.class.anonymization_config.guard.call(self)
          else
            return send(self.class.anonymization_config.guard)
          end
        end

        true
      end

      def _anonymize_columns
        nullify_hash = self.class.anonymization_config.attrs_to_nullify.inject({}) do |memo, attr|
          memo[attr] = nil
          memo
        end
        anonymize_hash =
          self.class.anonymization_config.attrs_to_anonymize.inject({}) do |memo, array|
            attr, proc = array
            if proc.respond_to?(:call)
              memo[attr] = proc.call(self)
            else
              memo[attr] = send(proc)
            end
            memo
          end

        update_hash = nullify_hash.merge anonymize_hash

        self.class.where(id: id).update_all(update_hash) unless update_hash.empty?
      end

      def _anonymize_by_call
        return if self.class.anonymization_config.attrs_to_anonymize.empty?
        update_hash = self.class.anonymization_config.attrs_to_anonymize.inject({}) do |memo, array|
          attr, proc = array
          if proc.respond_to?(:call)
            memo[attr] = proc.call(self)
          else
            memo[attr] = send(proc)
          end
          memo
        end
        self.class.where(id: id).update_all(update_hash)
      end

      def _anonymize_associations
        self.class.anonymization_config.associations_to_anonymize.each do |association|
          if send(association).respond_to?(:each)
            send(association).each { |a| a.send(:anonymize!) }
          elsif send(association)
            send(association).send(:anonymize!)
          end
        end
      end

      def _delete_associations
        self.class.anonymization_config.associations_to_delete.each do |association|
          if send(association).respond_to?(:each)
            send(association).each(&:delete)
          elsif send(association)
            send(association).delete
          end
        end
      end

      def _destroy_associations
        self.class.anonymization_config.associations_to_destroy.each do |association|
          if send(association).respond_to?(:each)
            send(association).each(&:destroy)
          elsif send(association)
            send(association).destroy
          end
        end
      end

      def _perform_post_anonymization_callbacks(original_attributes)
        self.class.anonymization_config.post_anonymization_callbacks.each do |callback|
          if callback.respond_to?(:call)
            callback.call(original_attributes)
          else
            send(callback, original_attributes)
          end
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:extend, Anonymizable)
end
