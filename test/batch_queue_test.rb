require "test_helper"
require 'batch_queue'

class BatchQueueTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::BatchQueue::VERSION
  end

  def setup
    Thread.abort_on_exception = true
  end

  def test_it_batches_at_max_batch
    is_processed = false
    bq = BatchQueue.new(max_batch_size: 2, max_interval_seconds: 1) do |arr|
      puts arr.inspect
      is_processed = true
    end

    bq << 'Yo'
    assert_equal 1, bq.size
    sleep(0.2)
    assert !is_processed

    bq << 'Whatsup'
    assert_equal 2, bq.size
    sleep(0.2)
    assert is_processed
    assert_equal 0, bq.size
  end

  def test_it_batches_at_max_interval
    is_processed = false
    bq = BatchQueue.new(max_batch_size: 2, max_interval_seconds: 1) do |arr|
      puts arr.inspect
      is_processed = true
    end

    bq << 'Yo'
    assert_equal 1, bq.size
    sleep(0.2)
    assert !is_processed
    sleep(1)
    assert is_processed
    assert_equal 0, bq.size
  end

  def test_it_handles_error
    is_error_handled = false

    bq = BatchQueue.new(max_batch_size: 2, max_interval_seconds: 1) do |_arr|
      raise 'an error'
    end

    bq.on_error do |err|
      is_error_handled = true
      assert_equal 'an error', err.message
    end

    bq << 'Yo'
    sleep(0.2)
    assert !is_error_handled

    bq << 'Whatsup'
    sleep(0.2)
    assert is_error_handled
  end

  def test_it_handles_close
    processed_count = 0
    bq = BatchQueue.new(max_batch_size: 2, max_interval_seconds: 1) do |arr|
      processed_count += 1
    end

    bq << 1
    sleep(0.2)
    assert_equal 1, bq.size
    assert_equal 0, processed_count
    bq.stop
    assert_equal 0, bq.size
    assert_equal 1, processed_count
  end

  def test_it_sets_thread_name
    thread_name = nil
    bq = BatchQueue.new(name: 'test-thread', max_batch_size: 1) do |arr|
      thread_name = Thread.current.name
    end

    bq << 'test'
    sleep(0.2)
    assert_equal 'test-thread', thread_name
    bq.stop
  end
end
