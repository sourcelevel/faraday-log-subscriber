require 'test_helper'
require 'active_support/log_subscriber/test_helper'


class ControllerRuntimeTest < ActionController::TestCase

  ActiveSupport::Deprecation.silence do
    TestRoutes = ActionDispatch::Routing::RouteSet.new
    TestRoutes.draw { get ':controller(/:action)' }
  end

  class LogSubscriberController < ActionController::Base
    include TestRoutes.url_helpers

    def zero
      render inline: 'Zero HTTP runtime'
    end

    def show
      Faraday::LogSubscriber.runtime += 100
      render inline: 'Takes 100ms'
    end

    def redirect
      Faraday::LogSubscriber.runtime += 100
      redirect_to 'http://example.com'
    end

    def faraday_after_render
      Faraday::LogSubscriber.runtime += 100
      render inline: 'Hello world'
      Faraday::LogSubscriber.runtime += 100
    end
  end


  include ActiveSupport::LogSubscriber::TestHelper
  tests LogSubscriberController


  def setup
    super
    @routes = TestRoutes
    ActionController::LogSubscriber.attach_to :action_controller
  end

  def teardown
    super

    ActiveSupport::LogSubscriber.log_subscribers.clear
    Faraday::LogSubscriber.reset_runtime
  end

  def set_logger(logger)
    ActionController::Base.logger = logger
  end

  def test_runtime_reset_before_requests
    Faraday::LogSubscriber.runtime += 12345
    get :zero
    wait

    assert_equal 2, @logger.logged(:info).size
    assert_match(/Faraday: 0.0ms\)/, @logger.logged(:info)[1])
  end

  def test_runtime_reset_between_requests
    get :show
    get :show
    wait

    assert_equal 4, @logger.logged(:info).size
    assert_match(/Faraday: 100.0ms\)/, @logger.logged(:info)[1])
    assert_match(/Faraday: 100.0ms\)/, @logger.logged(:info)[3])
  end

  def test_log_with_faraday_time_when_redirecting
    get :redirect
    wait

    assert_equal 3, @logger.logged(:info).size
    assert_match(/\(Faraday: [\d.]+ms\)/, @logger.logged(:info)[2])
  end

  def test_include_faraday_time_after_rendering
    get :faraday_after_render
    wait

    assert_equal 2, @logger.logged(:info).size
    assert_match(/Faraday: 200.0ms\)/, @logger.logged(:info)[1])
  end
end
