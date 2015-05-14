require "active_record"
require "anonymizable/configuration"

module Anonymizable
  class AnonymizeError < StandardError; end

  def self.extended(klass)

    klass.class_eval do

      class << self
        attr_reader :anonymization_config

        def anonymizable(*attrs, &block)
          @anonymization_config ||= Configuration.new(self)
          if block
            options = attrs.extract_options!
            @anonymization_config.send(:set_public) if options[:public]
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
            self.send(:private, :anonymize!)
          end
        end
      end

      private

        def _can_anonymize?
          if self.class.anonymization_config.guard
            if self.class.anonymization_config.guard.respond_to?(:call)
              return self.class.anonymization_config.guard.call(self)
            else
              return self.send self.class.anonymization_config.guard
            end
          end

          true
        end

        def _anonymize_columns
          nullify_hash    = self.class.anonymization_config.attrs_to_nullify.inject({}) {|memo, attr| memo[attr] = nil; memo}
          anonymize_hash  = self.class.anonymization_config.attrs_to_anonymize.inject({}) do |memo, array|
                              attr, proc = array
                              if proc.respond_to?(:call)
                                memo[attr] = proc.call(self)
                              else
                                memo[attr] = self.send(proc)
                              end
                              memo
                            end

          update_hash = nullify_hash.merge anonymize_hash

          self.class.where(id: self.id).update_all(update_hash) unless update_hash.empty?
        end

        def _anonymize_by_call
          return if self.class.anonymization_config.attrs_to_anonymize.empty?
          update_hash = self.class.anonymization_config.attrs_to_anonymize.inject({}) do |memo, array|
            attr, proc = array
            if proc.respond_to?(:call)
              memo[attr] = proc.call(self)
            else
              memo[attr] = self.send(proc)
            end
            memo
          end
          self.class.where(id: self.id).update_all(update_hash)
        end

        def _anonymize_associations
          self.class.anonymization_config.associations_to_anonymize.each do |association|
            if self.send(association).respond_to?(:each)
              self.send(association).each {|a| a.send(:anonymize!) }
            elsif self.send(association)
              self.send(association).send(:anonymize!)
            end
          end
        end

        def _delete_associations
          self.class.anonymization_config.associations_to_delete.each do |association|
            if self.send(association).respond_to?(:each)
              self.send(association).each {|r| r.delete}
            elsif self.send(association)
              self.send(association).delete
            end
          end
        end

        def _destroy_associations
          self.class.anonymization_config.associations_to_destroy.each do |association|
            if self.send(association).respond_to?(:each)
              self.send(association).each {|r| r.destroy}
            elsif self.send(association)
              self.send(association).destroy
            end
          end
        end

        def _perform_post_anonymization_callbacks(original_attributes)
          self.class.anonymization_config.post_anonymization_callbacks.each do |callback|
            if callback.respond_to?(:call)
              callback.call(original_attributes)
            else
              self.send(callback, original_attributes)
            end
          end
        end

    end

  end

end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:extend, Anonymizable)
end
