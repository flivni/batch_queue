$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "batch_queue"

require "minitest/autorun"
require 'minitest/reporters'

# Only use Minitest::Reporters if not running in RubyMine
Minitest::Reporters.use! unless ENV['RM_INFO']