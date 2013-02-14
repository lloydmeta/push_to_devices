# Encoding: UTF-8
# Credit to http://rubysource.com/simple-organized-queueing-with-resque/
class Queue::Base

  class << self

    def enqueue(object, method, *args)
      meta = { 'method' => method }

      ensure_queueable!(object, method, *args)

      if is_model?(object)
        Resque.enqueue(self, meta.merge('class' => object.class.name, 'id' => object.id), *args)
      else
        if object.name.nil? #to support calling active record observer models
          Resque.enqueue(self, meta.merge('class' => object.class.name), *args)
        else
          Resque.enqueue(self, meta.merge('class' => object.name), *args)
        end
      end
    end

    def perform(meta = { }, *args)
      if meta.has_key?('id')
        if model = meta['class'].constantize.find_by_id(meta['id'])
          model.send(meta['method'], *args)
        end
      else
        meta['class'].constantize.send(meta['method'], *args)
      end
    end

    def is_model?(object)
      object.class.respond_to?(:find_by_id)
    end

    private

      def ensure_queueable!(object, method, *args)
        ensure_responds_to!(object, method)
        ensure_arity!(object, method, args.length)
      end

      def ensure_responds_to!(object, method)
        unless object.respond_to?(method)
          raise "object must respond to #{method}"
        end
      end

      def ensure_arity!(object, method, arity)
        required = object.method(method).arity
        if required < 0 && arity < -required
          raise "#{method}: #{arity} of #{-required} arguments given"
        elsif required >= 0 && required != arity
          raise "#{method}: #{arity} of #{required} arguments given"
        end
      end
  end
end