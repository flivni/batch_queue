# BatchQueue

BatchQueue is queue that takes jobs and runs them, in aggregate, via a callback on a background thread.  You can process a “batch” of N jobs at a time or after T seconds whichever comes sooner.

## Example
You want to send metrics to Amazon’s AWS CloudWatch service every 60 seconds or when the batch size reaches 20, whichever comes first. You might write code like this:

```
# Create the AWS CloudWatch Client
cw_client = Aws::CloudWatch::Client.new(...)

# Set up the BatchQueue
BatchQueue.new(max_batch_size: 20, max_interval_seconds: 60) do |batch_metric_data|
    cw_client.put_metric_data(:metric_data => batch_metric_data)
end

# Add to the BatchQueue
@bq << {
    metric_name: 'Widgets',
    value: 1
}
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'batch_queue'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install batch_queue

## Usage

### 1. Set up the BatchQueue
Each BatchQueue gets its own background thread that executes jobs.
```
bq = BatchQueue.new(max_batch_size: 20, max_interval_seconds: 60) do |batch_metric_data|
    # Put your code that you want to execute here.
end
```

### 2. Add a job to the queue
You can add any object to the queue.
```
bq << {
    # your object here.
}

```
or
```
bq << MyJob.new(...)

```
### 3. Error handling
You have two options for handling errors in `BatchQueue`:

* Rescue exceptions within the processing block:

  ```
  bq = BatchQueue.new(max_batch_size: 20, max_interval_seconds: 60) do |batch_metric_data|
    begin
        # Put your code that you want to execute here.
    rescue => e
        # Handle the exception here.
    end
  end

  ```

* Set a global error handler:

  ```
  bq.on_error = ->(e) { puts e.message }
  ```

If neither method is used, `BatchQueue` will catch the exception and print it to 
the standard console output.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flivni/batch_queue.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
