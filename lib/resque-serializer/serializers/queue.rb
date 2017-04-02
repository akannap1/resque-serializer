module Resque
  module Plugins
    module Serializer
      module Serializers
        module Queue

          # before_enqueue: ✓
          #        enqueue: |
          #  after_enqueue: |
          # before_dequeue: |
          #        dequeue: |
          #  after_dequeue: ✗
          # before_perform:
          #        perform:
          #  after_perform:

          def before_enqueue_set_lock(*args)
            mutex(args).lock
          end

          def after_dequeue_clear_lock(*args)
            mutex(args).unlock
          end

          def mutex(args)
            Serializer::Mutex.new(key(args))
          end

          private

          def key(args)
            klass = self.name.tableize.singularize
            args  = args.map(&:to_s).join(',')

            "resque-serializer:#{klass}:#{args}"
          end
        end
      end
    end
  end
end
