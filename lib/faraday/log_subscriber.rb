module Faraday
  class LogSubscriber < ActiveSupport::LogSubscriber
    HTTP_METHOD_COLORS = Hash.new(MAGENTA)

    HTTP_METHOD_COLORS['POST'.freeze] = GREEN
    HTTP_METHOD_COLORS['GET'.freeze] = BLUE
    HTTP_METHOD_COLORS['PUT'.freeze] = YELLOW
    HTTP_METHOD_COLORS['DELETE'.freeze] = RED

    def self.runtime=(value)
      Thread.current['faraday_runtime'] = value
    end

    def self.runtime
      Thread.current['faraday_runtime'] ||= 0
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def http_cache(event)
      payload = event.payload

      status = payload[:cache_status]
      name = "Faraday HTTP Cache [#{status}]"
      request = payload[:env][:url]

      name = color(name, MAGENTA, true)
      request = color(request, nil, false)

      info "  #{name} #{request}"
    end

    def request(event)
      self.class.runtime += event.duration

      env = event.payload
      method = env[:method].to_s.upcase
      status = env[:status]
      name = format('%s %s [%s] (%.1fms)', 'Faraday', method, status, event.duration)
      body = env.body
      request = env[:url]

      name = color(name, nil, true)
      request = color(request, HTTP_METHOD_COLORS[method], true)

      info "  #{name} #{request}"
      if !env.success? && body.present?
        info "  #{name} #{body}"
      end
    end

    attach_to :faraday
  end
end
