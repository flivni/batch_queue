$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "batch_queue"

require "minitest/autorun"
require 'minitest/reporters'
MiniTest::Reporters.use!