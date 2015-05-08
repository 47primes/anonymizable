require "active_record"
require "anonymizable/configuration"

module Anonymizable
  class AnonymizeError < Exception; end

  def self.extended(klass)

    klass.class_eval do

      class << self
        attr_reader :anonymization_config

        def anonymizable(*attrs, &block)
          @anonymization_config = Configuration.new(self)
          if block
            @anonymization_config.instance_eval(&block)
          else
            @anonymization_config.attributes(*attrs)
          end

          define_method(:anonymize!) do
            return false unless _can_anonymize?

            original_attributes = attributes.dup
            transaction do
              _anonymize_by_nullification
              _anonymize_by_call
              _anonymize_associations
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

        def _anonymize_by_nullification
          update_hash = self.class.anonymization_config.attrs_to_nullify.inject({}) {|memo, attr| memo[attr] = nil; memo}
          self.class.where(id: self.id).update_all(update_hash)
        end

        def _anonymize_by_call
          self.class.anonymization_config.attrs_to_anonymize.each do |attr, proc|
            begin
              if proc.respond_to?(:call)
                update_attribute attr, proc.call(self)
              else
                update_attribute attr, self.send(proc)
              end
            rescue => e
              raise AnonymizeError.new("Anonymization of attribute #{attr} with #{proc} failed due to an error.\n#{e.message}\n#{caller.join("\n")}")
            end
          end
        end

        def _anonymize_associations
          self.class.anonymization_config.associations_to_anonymize.each do |association|
              if self.send(association).respond_to?(:each)
                begin
                  self.send(association).each {|a| a.send(:anonymize!) }
                rescue => e
                  raise AnonymizeError.new("Anonymization of collection #{association} failed due to an error.\n#{e.message}\n#{caller.join("\n")}")
                end
              elsif self.send(association)
                begin
                  self.send(association).send(:anonymize!)
                rescue => e
                  raise AnonymizeError.new("Anonymization of association #{association} failed due to an error.\n#{e.message}\n#{caller.join("\n")}")
                end                  
              end
            
          end
        end

        def _perform_post_anonymization_callbacks(original_attributes)
          self.class.anonymization_config.post_anonymization_callbacks do |callback|
            if callback.respond_to?(:call)
              callback.call(original_attributes)
            else
              self.send callback, original_attributes
            end
          end
        end

    end

  end

end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:extend, Anonymizable)
end
