class BatchQueue
  # starts the queue
  # either max_batch_size or interval_milliseconds or both must be set
  def initialize(max_batch_size: nil, max_interval_seconds: nil, &block)
    if max_batch_size.nil? && max_interval_seconds.nil?
      raise 'either max_batch_size or max_interval_seconds or both must be set'
    end
    @is_running = true
    @queue = Queue.new
    @block = block
    @max_batch_size = max_batch_size
    @max_interval_seconds = max_interval_seconds
    @mutex = Mutex.new
    @cond_var = ConditionVariable.new
    @runner = Thread.new { run }
  end

  # a block taking taking an exception as a parameter
  def on_error(&block)
    @on_error = block
  end

  def push(object)
    @mutex.synchronize do
      raise 'BatchQueue is stopped' unless @is_running
      @queue.push(object)
      @cond_var.signal
    end
    object
  end
  alias << push

  def size
    @mutex.synchronize do
      @queue.size
    end
  end

  private

  def run
    @mutex.synchronize do
      t0 = Time.now
      while @is_running do
        while (@queue.size >= @max_batch_size) ||
            (!@max_interval_seconds.nil? && @queue.size > 0 && Time.now >= t0 + @max_interval_seconds) do
          arr = []
          [@queue.size, @max_batch_size].min.times do
            arr << @queue.pop
          end
          @mutex.unlock
          begin
            @block.call(arr)
          rescue StandardError => exc
            @on_error.call(exc) if @on_error
          ensure
            @mutex.lock
          end
        end
        t0 = Time.now
        @cond_var.wait(@mutex, @max_interval_seconds)
      end
    end
  end

  # stops the queue and calls on_batch for all remaining
  def stop
    @mutex.synchronize do
      @is_running = false
    end
  end
end
