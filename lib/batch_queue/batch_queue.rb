class BatchQueue
  attr_reader :max_batch_size
  attr_reader :max_interval_seconds

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
    @on_error_callback = nil

    at_exit do
      stop
    end
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

  # stops the queue and signals to flush remaining queue, blocking until done.
  def stop
    @mutex.synchronize do
      @is_running = false
      @cond_var.signal
    end
    @runner.join
  end

  def on_error(&block)
    @on_error_callback = block
  end

  private

  def run
    @mutex.synchronize do
      t0 = Time.now
      while @is_running do
        while (@queue.size >= @max_batch_size) ||
            (!@max_interval_seconds.nil? && @queue.size > 0 && Time.now >= t0 + @max_interval_seconds) do
          arr = take_batch
          process_batch(arr)
        end
        t0 = Time.now
        @cond_var.wait(@mutex, @max_interval_seconds)
      end

      # exiting
      while @queue.size > 0
        arr = take_batch
        process_batch(arr)
      end
    end
  end


  def take_batch
    arr = []
    [@queue.size, @max_batch_size].min.times do
      arr << @queue.pop
    end
    arr
  end

  # we assume that we have the mutex lock before calling
  def process_batch(arr)
    @mutex.unlock
    begin
      @block.call(arr)
    rescue StandardError => e
      if @on_error_callback
        @on_error_callback.call(e)
      else
        puts "BatchQueue: Unhandled exception #{exc.inspect}"
      end
    ensure
      @mutex.lock
    end
  end
end
