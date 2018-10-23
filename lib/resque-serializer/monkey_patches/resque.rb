module MonkeyPatches
  module Resque
    # NOTE: `Resque#pop` is called when working queued jobs via the
    #       `resque:work` rake task. Resque's default implementation will not
    #       trigger the `before_dequeue` or `after_dequeue` hooks; this patch
    #       will force it do so.
    def pop(queue)
      return unless (job = decode(data_store.peek_in_queue(queue)))

      klass = job['class'].constantize
      args  = job['args']

      # Perform before_dequeue hooks. Don't perform dequeue if any hook returns
      # false
      before_hooks = Plugin.before_dequeue_hooks(klass).collect do |hook|
        klass.send(hook, *args)
      end
      return if before_hooks.any? { |result| result == false }

      super.tap do
        Plugin.after_dequeue_hooks(klass).each do |hook|
          klass.send(hook, *args)
        end
      end
    end
  end
end

module Resque
  prepend MonkeyPatches::Resque
end
