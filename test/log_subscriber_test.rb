require 'test_helper'
require 'active_support/log_subscriber/test_helper'

class LogSubscriberTest < ActiveSupport::TestCase
   include ActiveSupport::LogSubscriber::TestHelper

   def setup
     super
     Faraday::LogSubscriber.attach_to(:faraday)
   end

   def test_faraday_requests_are_logged
     connection.get('test')
     assert_match(/Faraday GET \[200\] \(.+\) http\:\/\/test\.host\/test/, @logger.logged(:info).last)
   end

   def test_failed_response_bodies_are_logged
     connection.get('notfound')

     assert_match(/Faraday GET \[404\] \(.+ms\) http\:\/\/test\.host\/notfound/, @logger.logged(:info).first)
     assert_match(/Faraday GET \[404\] \(.+ms\) Page Not Found/, @logger.logged(:info).last)
   end

  def connection
    @connection ||= Faraday.new('http://test.host') do |builder|
      builder.use :instrumentation
      builder.adapter :test, stubs
    end
  end

  def stubs
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') { |env| [200, {}, 'OK'] }
      stub.get('/notfound') { |env| [404, {}, 'Page Not Found'] }
    end
  end
end
