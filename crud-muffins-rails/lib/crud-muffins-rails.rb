require_relative "crud-muffins-rails/version"
require 'active_support'

module CrudMuffins
  module Rails
    # ApplicationAdapter is the general structure of a serializer. It returns data through `as_json`.
    #
    # We tried going through many different serializer libraries (FastJsonApi, ActiveModel Serializers, Roar,
    # Representable, and Grape) and they *all* didn't do what we want. Basically, we want something that can magically
    # convert snake_case to camelCase for us, to serve as a bridge between frontend and backend data representation
    # when necessary, and to return errors when the model has them.
    #
    # It turns out it was simpler to implement our own, which is what we've done here as a first pass.
    #
    # Adapters are intended to wrap an ApplicationRecord, and should be able to delegate basic operations
    # like `update` and `save` to the model, while still keeping it wrapped so it can return
    # serialized data.
    class Adapter
      # Chainable, immutable PORO that encapsulates an ActiveRecord::Collection, but can delegate `as_json` to map
      # the records through the provided adapter.
      class Collection
        attr_reader :collection, :adapter
        delegate :map, :last, to: :collection

        def initialize(collection, adapter)
          @collection = collection
          @adapter = adapter
        end

        def where(*args)
          @collection = collection.where(*args)
          self
        end

        def order(*args)
          @collection = collection.order(*args)
          self
        end

        def paginate(*args)
          @collection = collection.paginate(*args)
          self
        end

        def limit(*args)
          @collection = collection.limit(*args)
          self
        end

        def +(other)
          @collection = collection + other.collection
          self
        end

        def as_json(*)
          json = {
            data: collection.map { |obj| adapter.new(obj) },
          }

          if collection.respond_to?(:previous_page)
            json[:pagination] = {
              previous: collection&.previous_page,
              next: collection&.next_page
            }
          end

          json
        end
      end

      attr_reader :model
      private :model

      # the ApplicationRecord or other model class that it is an adapter for
      def self.model_class
        raise NotImplementedError
      end

      # general finder method that allows finding the record by ID within a scope, and wrapping it with the adapter
      def self.find(id, within: model_class)
        new(within.find(id))
      end

      # similar to Rails #find_or_create_by
      def self.find_or_create_by(where, within: model_class)
        new(within.find_or_create_by(where))
      end

      def self.within(within)
        Collection.new(within, self)
      end

      def self.where(*args)
        Collection.new(model_class.where(*args), self)
      end

      # makes a new model record with deserialized params and wraps it in the adapter
      def self.build(params)
        new(model_class.new(deserialize(params)))
      end

      # any logic needed to deserialize the params from the frontend, generally should be overridden
      def self.deserialize(params, _model = nil)
        params
      end

      delegate :deserialize, to: :class
      delegate_missing_to :model

      def initialize(model)
        @model = model
      end

      def as_json(*)
        {
          data: properties,
          type: type,
        }
      end

      def type
        model.class.to_s
      end

      # returns the serialized JSON object that will be passed to the frontend
      def properties
        raise NotImplementedError
      end

      def valid?
        model.valid?
      end

      def save
        model.save
      end

      # updates the model with the deserialized attributes
      def update(attributes)
        model.update(deserialize(attributes, model))
      end

      # general helper to create a hash with the specified model attributes where their key names are lowerCamelCased
      def serialize_props(*keys)
        keys.each_with_object({}) do |key, acc|
          acc[key.to_s.camelize(:lower).to_sym] = self.respond_to?(key) ? self.send(key) : model.send(key)
        end
      end

      # JSON object of the model errors and their full message summaries
      def errors
        {
          # Summary of all errors
          errors: model.errors.full_messages,
          # Errors associated with each attribute
          modelErrors: model.errors.messages.transform_keys { |key| key.to_s.camelize(:lower) }
        }
      end
    end
  end
end
