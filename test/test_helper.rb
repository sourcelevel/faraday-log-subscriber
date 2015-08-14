$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/setup'

require 'active_support'
require 'active_support/log_subscriber'

require 'faraday'
require 'faraday_middleware'

require 'faraday-log-subscriber'
require 'minitest/autorun'

ActiveSupport.test_order = :random
