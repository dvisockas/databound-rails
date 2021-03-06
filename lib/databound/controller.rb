module Databound
  class Controller
    class << self
      def find_or_create(name, resource, opts)
        find(name) || create(name, resource, opts)
      end

      def create(name, resource, opts)
        opts ||= {}
        Object.const_set(as_constant_string(name), new(resource, opts))
      end

      def new(resource, opts)
        model_name = opts.delete(:model) || fallback_model(resource)

        result = Class.new(ApplicationController)
        result.send(:databound) do
          model model_name

          opts.each do |key, value|
            send(key, *value)
          end
        end

        result
      end

      def fallback_model(resource)
        resource.to_s.classify.underscore.to_sym
      end

      def exists?(path)
        name_error = false

        begin
          as_constant_string(path).constantize
        rescue NameError
          name_error = true
        end

        !name_error
      end

      def find(path)
        as_constant_string(path).constantize if exists?(path)
      end

      def as_constant_string(name)
        "#{name.camelize}Controller"
      end
    end
  end
end
